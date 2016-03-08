# 斯品WEB前台前端项目

===

## 依赖

node 0.12+

```
$ npm install -g gulp
$ gem install sass
$ cd $project/sipin-web-frontend
$ npm install
```

## 构建命令

### npm start

前端开发模式： 编译并开启本地DEMO调试服务器

### npm run build

后端测试及线上版本： 编译静态资源至`./dist`目录

### gulp doc

基于jsdoc规范生成开发文档至`./doc`目录

## package.json
由package.json管理npm安装的依赖版本

## config.js

项目版本与基本配置config

### config.dirs

映射开发目录

### config.distName

映射构建目录

### config.hash

js构建是否加入hash值
