# @author weaves

# ISO date handling

from dateutil.parser import *
from dateutil.tz import *
from datetime import *

import csv

def isodt0(x, dayfirst=False):
    """
    :param x: a date string
    :type x: string
    :return ISO-formatted string, empty if an error

    Use date-parsing to clean up irregular date strings.
    HCC use a strange US format: m/d/yyyy hh:mm
    """
    # 
    s1 = ""
    try:
        s1 = parse(x, dayfirst=dayfirst)
    except:
        return s1
    
    return datetime.isoformat(s1)

    
def apply(tbl, n0, f=isodt0, tag='0'):
    """
    :param tbl: a table
    :type tbl: pandas table
    :param n0: column name
    :type n0: string
    :param f: a function
    :default f: isodt0

    :return same table with new column

    Apply the function on all the elements of the column, returns new column with '0'
    """
    n1 = n0 + tag
    tbl[n1] = tbl[n0].astype(str).apply(isodt0)
    return tbl

def to_csv(tbl, fname):
    tbl.to_csv(fname, sep=',', encoding='utf-8', index=False,
               quotechar='"', escapechar='\\',
               quoting=csv.QUOTE_NONNUMERIC)
