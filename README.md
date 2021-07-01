# tag 
<div align="center">


Git utility to create tags in order to identify specific releases


<img src="./assets/tag_demo.gif" width="500" />


</div>

---


### About 
`tag` script sets the version number according to the type of release (major, minor, patch), and previous version numbers. 

Tag version format : `MAJOR.MINOR.PATCH`. 

### Usage
- Add `tag` to PATH, for example : 
```
sudo cp tag /usr/local/bin
```

- Steps : 
```
tag
```

```
---------------------------
      Create tag
---------------------------

Latest tag released : 1.2.1

Select release type :
[ 1 ] major
[ 2 ] minor
[ 3 ] patch
> 1
Release type : major
```

```
Create and push tag with version : 2.0.0
Do you want to continue ? [Y/n]
Create tag 2.0.0 ...
Push tag 2.0.0 ...
Total 0 (delta 0), reused 0 (delta 0)
To github.com:PierreKieffer/app.git
 * [new tag]         2.0.0 -> 2.0.0
Tag 2.0.0 released
---------------------------
```


- Or create a tag directly with release type as argument : 
```
tag major || minor || patch
```

- If a tag already exists on the current commit : 
```
---------------------------
      Create tag
---------------------------

Latest tag released : 0.2.0

Select release type :
[ 1 ] major
[ 2 ] minor
[ 3 ] patch
> 1
Release type : major
Canceled
A tag already exists on this commit
Associated tag version : 0.2.0

---------------------------
```



