-- This file builds a database of SIL language information.  First download the data file
-- from http://www-01.sil.org/iso639%2D3/download.asp
-- Next create an sil database
-- Next create these tables in the sil database
-- Next rename the files to correspond to the table names
-- Next execute the mysqlimport commands

use sil;

CREATE TABLE ISO_639 (
Id char(3) NOT NULL,  -- The three-letter 639-3 identifier
Part2B  char(3) NULL,      -- Equivalent 639-2 identifier of the bibliographic applications 
                                    -- code set, if there is one
Part2T  char(3) NULL,      -- Equivalent 639-2 identifier of the terminology applications code 
                                    -- set, if there is one
Part1   char(2) NULL,      -- Equivalent 639-1 identifier, if there is one    
Scope   char(1) NOT NULL,  -- I(ndividual), M(acrolanguage), S(pecial)
Type    char(1) NOT NULL,  -- A(ncient), C(onstructed),  
                                    -- E(xtinct), H(istorical), L(iving), S(pecial)
Ref_Name   varchar(150) NOT NULL,   -- Reference language name 
Comment    varchar(150) NULL);       -- Comment relating to one or more of the columns
         
CREATE TABLE ISO_639_Names (
 Id             char(3)     NOT NULL,  -- The three-letter 639-3 identifier
 Print_Name     varchar(75) NOT NULL,  -- One of the names associated with this identifier 
 Inverted_Name  varchar(75) NOT NULL);  -- The inverted form of this Print_Name form  

CREATE TABLE ISO_639_Macrolanguages (
  M_Id      char(3) NOT NULL,   -- The identifier for a macrolanguage
  I_Id      char(3) NOT NULL,   -- The identifier for an individual language
                                       -- that is a member of the macrolanguage
  I_Status  char(1) NOT NULL);   -- A (active) or R (retired) indicating the
                                       -- status of the individual code element 
CREATE TABLE ISO_639_Retirements (
  Id          char(3)      NOT NULL,     -- The three-letter 639-3 identifier
  Ref_Name    varchar(150) NOT NULL,     -- reference name of language
  Ret_Reason  char(1)      NOT NULL,     -- code for retirement: C (change), D (duplicate),
                                                -- N (non-existent), S (split), M (merge)
  Change_To   char(3)      NULL,         -- in the cases of C, D, and M, the identifier 
                                                -- to which all instances of this Id should be changed
  Ret_Remedy  varchar(300) NULL,         -- The instructions for updating an instance
                                                -- of the retired (split) identifier
  Effective   date         NOT NULL);     -- The date the retirement became effective  

create table DEVICE_LOCALES (
  id char(3) NULL,
  part1 varchar(10) null,
  country char(2) null,
  name varchar(40) null,
  iphone char(1) null,
  iphoneOther char(1) null,
  android char(1) null,
  sil_name varchar(40),
  comment varchar(40));   

mysqlimport -uroot -proot --ignore-line=1 --local sil '/Users/garygriswold/Downloads/iso_639/ISO_639.txt'

mysqlimport -uroot -proot --ignore-line=1 --local sil '/Users/garygriswold/Downloads/iso_639/ISO_639_Names.txt'

mysqlimport -uroot -proot --ignore-line=1 --local sil '/Users/garygriswold/Downloads/iso_639/ISO_639_Macrolanguages.txt'

mysqlimport -uroot -proot --ignore-line=1 --local sil '/Users/garygriswold/Downloads/iso_639/ISO_639_Retirements.txt'

mysqlimport -uroot -proot --ignore-line=1 --fields-terminated-by="," --local sil '/Users/garygriswold/BibleApp/Server/sil_db/device_locales.csv'

----- VERIFICATION SCRIPTS -----

select id from device_locales where id not in (select id from iso_639); -- we want no results

select i.id, i.part1, l.part1, i.ref_name, l.name 
from iso_639 i join device_locales l on i.id=l.id 
where i.part1 != l.part1;
