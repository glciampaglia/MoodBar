#!/usr/bin/env python
# encoding: utf8

from contextlib import closing
from urllib2 import urlopen
import json
import re

h = "http://en.wikipedia.org"

def active_bots():
    # from: Wikipedia:Bots/Status
    q = "/w/api.php?action=query&prop=revisions&format=json&rvprop=content&rvlimit=1&rvdir=newer&titles=Wikipedia%3ABots%2FStatus%2Factive_bots"
    pat = r"\{\{\w+\|(?P<user_name>\w+)"
    x = re.compile(pat)
    with closing(urlopen(h + q)) as r:
        j = json.load(r, encoding='utf-8')
    rev_id = j["query"]["pages"].keys()[0]
    rev_text = j["query"]["pages"][rev_id]['revisions'][0]['*']
    return map(str, x.findall(rev_text))

def bots_by_number():
    # from: Wikipedia:List of bots by number of edits
    q = "/w/api.php?action=query&prop=revisions&format=xml&rvprop=content&rvlimit=1&rvdir=newer&rvexpandtemplates=&export=&exportnowrap=&titles=Wikipedia%3AList%20of%20bots%20by%20number%20of%20edits%2F1%E2%80%931000"
    pat = r"""^\|\ 
        (?P<user_name>[a-zA-Z]\w+)
        |
        \[\[User:\w+\|(?P<user_name_link>\w+)\]\]"""
    x = re.compile(pat, re.MULTILINE | re.VERBOSE)
    table_lines = []
    with closing(urlopen(h + q)) as r:
        text = '\n'.join(r.readlines())
    return list(filter(None, reduce(tuple.__add__, x.findall(text))))

if __name__ == '__main__':
     bots = set(active_bots() + bots_by_number())
     for l in sorted(bots):
         print l
