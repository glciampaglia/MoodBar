#!/usr/bin/env python
# encoding: utf8

import sys
from contextlib import closing
from urllib2 import urlopen, HTTPError
import json
import re
from codecs import utf_8_decode, utf_8_encode
from itertools import imap, repeat
import oursql

h = "http://en.wikipedia.org"

q_temp_table = """
create temporary table giovanni.bot_temp ( user_name varbinary(255) );
"""

q_temp_insert = """ insert giovanni.bot_temp set user_name = ? """

q_temp_delete = """ delete from giovanni.bot_temp where user_name = ? """

# finds user names in bot list that do not correspond to any user_name in user
q_test = """select user_name from user right join giovanni.bot_temp using
    (user_name) where user_id is null"""

# finds original user_name of renamed accounts
q_redirect = """ select user_name from page join redirect on page_id = rd_from
join user on user_name = rd_title where page_namespace = 2 and page_title = ? """

q_table_delete = """ drop table if exists giovanni.bot """

q_table = """ 
create table giovanni.bot ( user_id int not null, user_name varbinary(255),
constraint foreign key bot_user_id (user_id) references user (user_id)) select 
distinct user_id, user_name from giovanni.bot_temp join user using (user_name)
"""

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

def active_bots():
    # from: Wikipedia:Bots/Status
    q = "/w/api.php?action=query&prop=revisions&format=json&rvprop=content&rvlimit=1&rvdir=newer&titles=Wikipedia%3ABots%2FStatus%2Factive_bots"
    pat = r"^\{\{\w+\|(?P<user_name>.+?)\|"
    x = re.compile(pat, re.MULTILINE)
    with closing(urlopen(h + q)) as r:
        j = json.load(r, encoding='utf-8')
    rev_id = j["query"]["pages"].keys()[0]
    rev_text = j["query"]["pages"][rev_id]['revisions'][0]['*']
    return x.findall(rev_text) #, rev_text

def bots_by_number():
    # from: Wikipedia:List of bots by number of edits
    q = "/w/api.php?action=query&prop=revisions&format=xml&rvprop=content&rvlimit=1&rvdir=newer&rvexpandtemplates=&export=&exportnowrap=&titles=Wikipedia%3AList%20of%20bots%20by%20number%20of%20edits%2F1%E2%80%931000"
    pat = r"""^\|\ 
        (?P<user_name>[a-zA-Z].+)
        |
        \[\[User:\w+\|(?P<user_name_link>.+?)\]\]"""
    x = re.compile(pat, re.MULTILINE | re.VERBOSE)
    table_lines = []
    with closing(urlopen(h + q)) as r:
        text = '\n'.join(r.readlines())
    bots = list(filter(None, reduce(tuple.__add__, x.findall(text))))
    bots = map(utf_8_decode, bots)
    bots = zip(*bots)[0]
    return list(bots)

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
        cu.execute('select user_name from giovanni.bot where user_name = ?',
                cand_row)
        if cu.fetchone():
            pass
        else:
            unmatched.append(cand_row)

    # return any unmatched candidates
    return unmatched

if __name__ == '__main__':

    # retrieve bot lists
    b1 = active_bots()
    b2 = bots_by_number()

    # normalize user names
    bots = normalize_user_names(set(b1 + b2))
    print '{} names (incl. redirects) found from bots list'.format(len(bots))

    # the database session corresponds to the scope of this with statement
    with closing(oursql.connect(read_default_file='~/.my.cnf')) as conn:

        # create bots table
        unmatched_bots = create_table(conn, bots)

    if len(unmatched_bots):
        print 'unidentfied bots: {}'.format(len(unmatched_bots))
        import pprint
        pprint.pprint(unmatched_bots)
    else:
        print 'all bots successfully identified!'

