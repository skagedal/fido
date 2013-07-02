from __future__ import print_function
import sqlite3
import time
from datetime import datetime

def adapt_datetime(ts):
    return int(time.mktime(ts.timetuple()))

sqlite3.register_adapter(datetime, adapt_datetime)

def pp(cursor, data=None, rowlens=0):
    d = cursor.description
    if not d:
        return "#### NO RESULTS ###"
    names = []
    lengths = []
    rules = []
    if not data:
        data = cursor.fetchall()
    for dd in d:    # iterate over description
        l = dd[1]
        if not l:
            l = 12             # or default arg ...
        l = max(l, len(dd[0])) # handle long names
        names.append(dd[0])
        lengths.append(l)
    for col in range(len(lengths)):
        if rowlens:
            rls = [len(str(row[col])) for row in data if row[col]]
            lengths[col] = max([lengths[col]]+rls)
        rules.append("-"*lengths[col])
    format = " ".join(["%%-%ss" % l for l in lengths])
    result = [format % tuple(names)]
    result.append(format % tuple(rules))
    for row in data:
        result.append(format % row)
    return "\n".join(result)

def create_tables(c):
    c.execute('''
        CREATE TABLE items (
            item_title               TEXT,
            item_content             TEXT,
            item_posted              INTEGER,
            item_updated             INTEGER,
            item_is_read             INTEGER DEFAULT 0,
            item_mute                INTEGER,
            feed_id                  INTEGER NOT NULL
        )
    ''')
    c.execute('''
        CREATE TABLE feeds (
            feed_id                  INTEGER PRIMARY KEY,
            feed_title               TEXT,
            feed_metadata            TEXT,
            feed_priority            INTEGER DEFAULT 0,
            feed_mute                INTEGER
        )
    ''')

STEVES_FOOD = 1
FRIEND_TOM = 2
WORK_STUFF = 3
TIME_WASTE = 4

def create_feeds(c):
    c.executemany('''INSERT INTO feeds (feed_title, feed_id, feed_priority) VALUES (?, ?, ?)''', 
                  [("Steve's Food",     STEVES_FOOD,    0), 
                   ('Friend Tom',       FRIEND_TOM,     2),
                   ('Work Stuff',       WORK_STUFF,     1),
                   ('Time Waste',       TIME_WASTE,     0)])
  
def create_items(c):
    c.executemany('''
        INSERT INTO items (
            item_title, 
            feed_id,
            item_is_read,
            item_updated
        ) VALUES (?, ?, ?, ?)''',
                  [('Sandwich!',        STEVES_FOOD,    False,  datetime(2012, 11, 01)),
                   ('Work more!',       WORK_STUFF,     False,  datetime(2011, 01, 05)),
                   ('Work less!',       WORK_STUFF,     False,  datetime(2010, 01, 05)),
                   ('Tom says Hi!',     FRIEND_TOM,     False,  datetime(2009, 01, 01)),
                   ('Old sandwich',     STEVES_FOOD,    True,   datetime(2008, 01, 01))
                   ])

def test():
    conn = sqlite3.connect(':memory:')
    c = conn.cursor()
    create_tables(c)
    create_feeds(c)
    create_items(c)

    # c.execute('SELECT * FROM feeds')
    # print ()
    # print (pp (c))

    # c.execute('SELECT * FROM items')
    # print ()
    # print (pp (c))

    c.execute("""
                 SELECT item_title, feed_title, feed_priority, item_updated FROM items, feeds USING (feed_id)
                   WHERE item_is_read = 0
                   ORDER BY feed_priority DESC, item_updated 
              """)
    print ()
    print (pp (c))
  
    print ()
    return conn

test()
