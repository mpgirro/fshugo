# fshugo: file system search engine

This is a webservice based file system search engine. 

## Populate file system info database

In order populate the database structure needed to perform search options, their is a script in ```lib``` called ```invimport.rb```. It takes a inventory file (currently only JSON file types are supported) created by the [fsinv](https://github.com/mpgirro/fsinv) tool. There are two imporz modi available:

**new**: will purge any existing database and repopulate it from scratch

**extend**: will add a given inventory structure to the existing data pool. Use this to make search available for multiple file system not necessarily being connected in any way