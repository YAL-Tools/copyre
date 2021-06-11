# copyre

Copies a directory while replacing strings in files.

Mostly handy for creating "templates" for multi-tool projects
(e.g. my GameMaker extensions often have a C++ or Haxe project and 3 GameMaker projects for different target versions).

## How to use
```
copyre .../source_path .../destination_path [old name] [new name]
```
If `old name` or `new name` are not set, they default to name of the directory.

For example,
```
copyre D:/baseProject D:/newProject TemplateProject
```
This would copy all files from `baseProject` to `newProject`
while replacing `TemplateProject` in files by `newProject`.

## Advanced use
Directories may contain a `.copyre` file with additional overrides as pairs of lines, e.g.
```
old name 1
new name 1
old name 2
new name 2
```
New names can also be:

* `${newName}`: target name (like `newProject` for example above)
* `${newname}`: target name in lower-case (like `newproject`)
* `${NEWNAME}`: target name in upper-case (like `NEWPROJECT`)
* `${new_guid}`: a random lower-case GUID
* `${NEW_GUID}`: a random upper-case GUID

## Compiling

```
haxe -cp src -neko copyre.n -main Main
```