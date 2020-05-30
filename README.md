## More info to be added.
This is more or less not really a fork. This version allows for multiple databases, tables, types of data, and so much more.



## Authors Notes:
MySQL PData is a simple and effecient way to save strings using MySQL without the need of creating multiple, scattered out scripts relying on different databases and tables. The installation process is extremely straightforward, simply drag 'n' drop the repository contents and insert your database details in `lua/mysql_pdata/sv_config.lua`. Please keep in mind that this is supposed to be used as a MySQL wrapper for your scripts, you should only add this to your addons once and after that simply use the functions explained below. 

### Usage 
Similarily to PData this only allows saving strings, that being said you're able to save data types that can be converted to string using [tostring](https://wiki.facepunch.com/gmod/Global.tostring), for example integers. You can also, in theory, store tables using [util.TableToJSON](https://wiki.facepunch.com/gmod/util.TableToJSON). This has not been intensively tested, which means there could be some errors or sub-optimal solutions - I encourage everyone to submit issues/pull requests.

### Credits
- [fesh](https://steamcommunity.com/profiles/76561198139510546) (Help) 
- [GlorifiedPig](https://steamcommunity.com/id/GlorifiedPig/) (Idea & Help) 
- [FredyH](https://github.com/FredyH/MySQLOO) (MySQLOO) 
- [SaturdaysHeroes](https://github.com/SaturdaysHeroes/mysql-pdata) (Orignal Project)
