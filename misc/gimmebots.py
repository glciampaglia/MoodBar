#!/usr/bin/env python
# encoding: utf8

import sys
from contextlib import closing
from urllib2 import urlopen, HTTPError
import json
import re
from codecs import utf_8_decode, utf_8_encode
from itertools import imap, repeat

try:
    from MySQLdb import connect
except ImportError:
    from oursql import connect

h = "http://en.wikipedia.org"
userdb = "giovanni"

q_temp_table = """
create temporary table %s.bot_temp ( user_name varbinary(255) );
""" % userdb

q_temp_insert = """ insert %s.bot_temp set user_name = ? """ % userdb

q_temp_delete = """ delete from %s.bot_temp where user_name = ? """ % userdb

# finds user names in bot list that do not correspond to any user_name in user
q_test = """select user_name from user right join %s.bot_temp using
    (user_name) where user_id is null""" % userdb

# finds original user_name of renamed accounts
q_redirect = """ select user_name from page join redirect on page_id = rd_from
join user on user_name = rd_title where page_namespace = 2 and page_title = ? """

q_table_delete = """ drop table if exists %s.bot """ % userdb

q_table = """ 
create table %(userdb)s.bot ( user_id int not null, user_name varbinary(255),
constraint foreign key bot_user_id (user_id) references user (user_id)) select 
distinct user_id, user_name from %(userdb)s.bot_temp join user using (user_name)
""" % { "userdb" : userdb }

def split(seq, chunk_len):
    ''' split seq in chunks of chunk_len. Returns a list of chunks. '''
    if len(seq) <= chunk_len:
        return [ seq ]
    else:
        chunks = []
        while len(seq):
            chunk = list(seq[:chunk_len])
            chunks.append(chunk)
            del seq[:chunk_len]
        return chunks

def normalize_user_names(names):
    ''' 
    Query the wikipedia API for normalized version of passed names. Breaks down
    the input list in chunks for 50 for speeding up queries. 
    '''
    err_msg = 'ERROR: received {} querying {}'
    q = r"/w/api.php?action=query&prop=info&format=json&inprop=displaytitle&titles={}"
    normalized = []
    # encode everythin in UTF-8
    names = list(zip(*map(utf_8_encode, names))[0])

    # split input in chunks of max 50 names
    names_splitted = split(names, 50)

    # holds the return values
    norm_names = []

    # for each chunk query the WP API, create a JSON object with the result
    for names_chunk in names_splitted:
        titles = '|'.join(imap(str.__add__, repeat('User:'), names_chunk)).replace(' ', '%20')
        url = h + q.format(titles)
        with closing(urlopen(url)) as r:
            j = json.load(r, encoding='utf-8')
            j = j['query']

        # if return object has a 'normalized' section, create a translation
        # dictionary with its entries, and use it to get the normalized names
        if j.has_key('normalized'):
            norm_dict = dict([ (d['from'], d['to']) for d in j['normalized'] ])
        else:
            norm_dict = {}
        for b in names_chunk:
            if 'User:' + b in norm_dict:
                _, norm_name_name = norm_dict['User:' + b].split(':')
                norm_names.append(norm_name_name)
            else:
                norm_names.append(b)
    return norm_names

_H = 'https://en.wikipedia.org'
_Q = "/w/api.php?action=query&prop=revisions&format=json&rvprop=content&rvlimit=1&titles={}"

def get_latest_revision(title):
    ''' queries the API for the text of latest revision of given title '''
    url = _H + _Q.format(title.replace(' ', '_'))
    with closing(urlopen(url)) as resp:
        j = json.load(resp, encoding='utf-8')
    k = j['query']['pages'].iterkeys().next()
    return j['query']['pages'][k]['revisions'][0]['*']

_pat_BotS = r"""
^
\{\{
BotS
\|
(?P<user_name>.+?)
\|
"""

_re_BotS = re.compile(_pat_BotS, re.MULTILINE | re.VERBOSE | re.UNICODE)

def scrape_BotS_template(title):
    ''' scrape user names of bots from a list of BotS templates '''
    rev_text = get_latest_revision(title)
    return _re_BotS.findall(rev_text) 

def scrape_table(title):
    ''' scrape user names from rows for a table '''
    rev_text = get_latest_revision(title)
    table_rows = map(lambda k : k.replace('\n', ''), rev_text.split('|-'))
    matches = []
    for row in table_rows:
        fields = row.split('|')
        n = len(fields)
        if n == 5:
            name = fields[3].strip(']')
        elif n == 4:
            name = fields[2]
        else:
            continue
        matches.append(name.strip())
    return matches

def create_table(conn, bots):
    bots = zip(*map(utf_8_decode, bots))[0]
    cu = conn.cursor()

    # create temp table and insert user names of bots
    cu.execute(q_temp_table)
    cu.executemany(q_temp_insert, zip(bots))

    # retrieve user names that do not match with names in user table. These are
    # candidates for being redirected user names
    cu.execute(q_test)
    redirect_candidates = cu.fetchall()

    # test redirect candidates. 
    if redirect_candidates:
        matched_candidates = []
        redirect_originals = []
        unmatched_candidates = []
        
        # for each candidate, check if a redirect exists and reconstruct from it
        # the original user name
        for cand_row in redirect_candidates:
            (candidate,) = cand_row
            cu.execute(q_redirect, cand_row)
            result = cu.fetchone()
            
            if result:
                redirect_originals.append(result)
                matched_candidates.append(cand_row)
            else:
                unmatched_candidates.append(cand_row)

        # if any originals were found, update them in the temp table
        if redirect_originals:
            cu.executemany(q_temp_insert, redirect_originals)
            cu.executemany(q_temp_delete, matched_candidates)

    cu.execute(q_table_delete)
    cu.execute(q_table)

    unmatched = []
    for i in xrange(len(unmatched_candidates)):
        cand_row = unmatched_candidates.pop()
        cu.execute('select user_name from %s.bot where user_name = ?' % userdb,
                cand_row)
        if cu.fetchone():
            pass
        else:
            unmatched.append(cand_row)

    # return any unmatched candidates
    return unmatched

if __name__ == '__main__':

    # retrieve bot lists
    b1 = scrape_BotS_template('Wikipedia:Bots/Status/active_bots')
    b2 = scrape_BotS_template('Wikipedia:Bots/Status/inactive_bots')
    b3 = scrape_table('Wikipedia:List_of_bots_by_number_of_edits/1–1000')

    # normalize user names and remove dups
    bots = set(normalize_user_names(set(b1 + b2 + b3)))
    print '{} names (incl. redirects) found from bots list'.format(len(bots))

    # the database session corresponds to the scope of this with statement
    with closing(connect(read_default_file='~/.my.cnf')) as conn:

        # create bots table
        unmatched_bots = create_table(conn, bots)

    if len(unmatched_bots):
        print 'unidentfied bots: {}'.format(len(unmatched_bots))
        import pprint
        pprint.pprint(unmatched_bots)
    else:
        print 'all bots successfully identified!'

