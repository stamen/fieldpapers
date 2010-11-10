from sys import argv
from re import compile
import MySQLdb

if __name__ == '__main__':

    pat = compile(r'^(http://.+/scans/(\w+))/([^/]+)$')

    db = {'user': argv[1], 'passwd': argv[2], 'db': argv[3], 'host': argv[4]}
    db = MySQLdb.connect(**db).cursor()
    
    db.execute('SELECT content FROM messages WHERE content LIKE "http://%"')
    
    for (url, ) in db.fetchall():
        match = pat.match(url)
        
        if match:
            base_url, scan_id, uploaded_file = [match.group(i) for i in (1, 2, 3)]
            
            rows = db.execute('SELECT base_url, uploaded_file FROM scans WHERE id = %s', (scan_id, ))
            
            if rows == 0:
                continue
            
            actual_base_url, actual_uploaded_file = db.fetchone()
            
            if actual_uploaded_file is not None:
                continue
            
            if actual_base_url != base_url:
                raise Exception('failed match', actual_base_url, base_url)

            db.execute('UPDATE scans SET created = created, uploaded_file = %s WHERE id = %s', (uploaded_file, scan_id))
            
            print scan_id, '-', base_url, uploaded_file

    db.connection.commit()
