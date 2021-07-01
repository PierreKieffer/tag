# tag 
<div align="center">


Create tags to identify specific release version


<img src="tag_demo.gif" width="500" />


</div>

---


## About 
`tag` script sets the version number according to the type of release (major, minor, patch), and previous version numbers. 

Tag version format : `MAJOR.MINOR.PATCH`. 

## Usage
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

Latest tag released : 0.2.0

Select release type :
[ 1 ] major
[ 2 ] minor
[ 3 ] patch
> 1
Release type : major
```

```
Create and push tag with version : 1.2.0
Do you want to continue ? [Y/n]
Create tag 1.2.0 ...
Push tag 1.2.0 ...
Total 0 (delta 0), reused 0 (delta 0)
To github.com:PierreKieffer/app.git
 * [new tag]         1.2.0 -> 1.2.0
Tag 1.2.0 released
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




