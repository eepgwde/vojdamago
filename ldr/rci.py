#!/usr/bin/env python3

# -*- coding: utf-8 -*-

import os
import datetime

import pandas as pd
import numpy as np

import isodtg

import re
import sys


def main():
    # print("working: " + sys.argv[1])
    nsheet=int(0)
    if len(sys.argv) >= 4:
        nsheet=int(sys.argv[3])

    tbl = pd.read_excel(sys.argv[1], sheet_name=nsheet)

    tbl = isodtg.apply(tbl, 'survey_feat_end', f=isodtg.isodt0)    
    isodtg.to_csv(tbl, sys.argv[2])

if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(main())
