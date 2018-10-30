# Galleon
ROS based event driven control and visualization toolkit for Pharos. A video demo available here: [https://www.youtube.com/watch?v=AOJ-23YpqGY](https://www.youtube.com/watch?v=AOJ-23YpqGY)

![](https://github.com/lxsang/Galleon/raw/master/galleon.png)

Galleon is developed on top of : [PhaROS](http://car.imt-lille-douai.fr/category/software/pharos/), a ROS based client for Pharo, it defines a set of control and visualization API that facilitates the development of robotic application from Pharo

## Installing

```smalltalk
Metacello new
	repository: 'github://lxsang/Galleon';
	baseline:'Galleon';
	load
```
