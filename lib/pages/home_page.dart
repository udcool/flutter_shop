import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_shop/service/service_method.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_shop/widget/ad_banner_widget.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
// import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {

  int page = 1;
  List<Map> hotGoodsList = [];

  Widget hotTitle = Container(
    margin: EdgeInsets.only(top: 10.0),
    padding: EdgeInsets.all(5.0),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(width: 0.5, color: Colors.black12))),
      child: Text('火爆专区'),
  );

  /// 火爆专区子项
  Widget _wrapList() {
    if (hotGoodsList.length != 0) {
      List<Widget> listWidget = hotGoodsList.map((val) {
        return InkWell(
          onTap: () {print('点击了火爆商品');},
          child: Container(
            width: ScreenUtil().setWidth(372),
            color: Colors.white,
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.only(bottom: 3.0),
            child: Column(
              children: <Widget>[
                Image.network(val['image'], width: ScreenUtil().setWidth(375)),
                Text(val['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.pink, fontSize: ScreenUtil().setSp(26))),
                Row(
                  children: <Widget>[
                    Text('￥${val['mallPrice']}'),
                    Text('￥${val['price']}', style: TextStyle(color: Colors.black26, decoration: TextDecoration.lineThrough),)
                  ],
                )
              ],
            ),
          ),);
      }).toList();

      return Wrap(spacing: 2, children: listWidget,);
    } else {
      return Text(' ');
    }
  }

  /// 火爆专区组合
  Widget _hotGoods() {
    return Container(child: Column(
      children: <Widget>[
        hotTitle,
        _wrapList()
      ],
    ),);
  }

  void _getHotGoods() {
    var query = {'page': page};
    request('getHomePageBelowConten', query: query).then((val) {
      var data = json.decode(val.toString());
      print(data);
      List<Map> newGoodsList = (data['data'] as List).cast();
      setState(() {
        hotGoodsList.addAll(newGoodsList);
        page++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    return Scaffold(
      appBar: AppBar(title: Text('百姓生活+'),),
      body: FutureBuilder(
        future: getHomePageContent(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = json.decode(snapshot.data.toString());
            List<Map> swiperDataList = (data['data']['slides'] as List).cast(); // 顶部轮播组件数据
            List<Map> navigatorList = (data['data']['category'] as List).cast();
            String advertesPicture = data['data']['advertesPicture']['PICTURE_ADDRESS'];

            String leaderImage = data['data']['shopInfo']['leaderImage']; // 店长图片
            String leaderPhone = data['data']['shopInfo']['leaderPhone']; // 店长电话
            List<Map> recommendList = (data['data']['recommend'] as List).cast();

            String floor1Title = data['data']['floor1Pic']['PICTURE_ADDRESS'];
            String floor2Title = data['data']['floor2Pic']['PICTURE_ADDRESS'];
            String floor3Title = data['data']['floor3Pic']['PICTURE_ADDRESS'];
            List<Map> floor1 = (data['data']['floor1'] as List).cast();
            List<Map> floor2 = (data['data']['floor2'] as List).cast();
            List<Map> floor3 = (data['data']['floor3'] as List).cast();

            if (navigatorList.length > 10) {
              navigatorList.removeRange(10, navigatorList.length);
            }
            return EasyRefresh(
              child: ListView(
                children: <Widget>[
                  SwiperDiyWidget(swiperDataList: swiperDataList,),
                  TopNavigator(navigatorList: navigatorList,),
                  AdBannerWidget(advertesPicture: advertesPicture,),
                  LeaderPhone(leaderImage: leaderImage, leaderPhone: leaderPhone,),
                  Recommend(recommendList: recommendList,),
                  FloorTitle(picture_address: floor1Title,),
                  FloorContent(floorGoodsList: floor1,),
                  
                  FloorTitle(picture_address: floor2Title,),
                  FloorContent(floorGoodsList: floor2,),

                  FloorTitle(picture_address: floor3Title,),
                  FloorContent(floorGoodsList: floor3,),
                  _hotGoods(),
                ],
              ),
              loadMore: () async {
                print('开始加载更多');
                _getHotGoods();
              },
              // refreshFooter: ClassicsFooter(
                // key: _footerKey,
                // bgColor: Colors.white,
                // textColor: Colors.pink,
                // moreInfoColor: Colors.pink,
                // showMore: true,
                // noMoreText: '',
                // moreInfo: '加载中',
                // loadReadyText: '上拉加载...',
              // ),
            );
          } else {
            return Center(
              child: Text('加载中'),
            );
          }
        },
      ),);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getHotGoods();
  }
}

class SwiperDiyWidget extends StatelessWidget {

  final List swiperDataList;
  SwiperDiyWidget({Key key, this.swiperDataList}):super(key:key);

  @override
  Widget build(BuildContext context) {
    
    return Container(
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Image.network("${swiperDataList[index]['image']}", fit: BoxFit.fill);
        },
        itemCount: swiperDataList.length,
        pagination: new SwiperPagination(),
        autoplay: true
      ),
    );
  }
}

class TopNavigator extends StatelessWidget {
  final List navigatorList;
  TopNavigator({Key key, this.navigatorList}) : super(key: key);

  Widget _gridViewItemUI(BuildContext context, item) {
    return InkWell(
      onTap: () {print('点击了导航');},
      child: Column(
        children: <Widget>[
          Image.network(item['image'], width: ScreenUtil().setWidth(95)),
          Text(item['mallCategoryName'])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(3.0),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        padding: EdgeInsets.all(4.0),
        children: navigatorList.map((item) {
          return _gridViewItemUI(context, item);
        }).toList(),
      ),
    );
  }
}

class LeaderPhone extends StatelessWidget {
  final String leaderImage; // 店长图片
  final String leaderPhone; // 店长电话

  LeaderPhone({Key key, this.leaderImage, this.leaderPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(onTap: () {
        _launchURL();
      },
      child: Image.network(leaderImage),),

    );
  }

  void _launchURL() async {
    String url = 'tel:' + leaderPhone;
    // if (await canLaunch(url)) {
      // await launch(url);
    // } else {
      // throw 'Count not launch $url';
    // }
  }
}

class Recommend extends StatelessWidget {
  final List recommendList;

  Recommend({Key key, this.recommendList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(380),
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          _titleWidget(),
          _recommendList()
        ],
      ),
    );
  }


  Widget _titleWidget() {
    return Container(child: Text('商品推荐', style: TextStyle(color: Colors.pink),),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(10.0, 2.0, 0, 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 0.5, color: Colors.black12)
        )
      ),
    );
  }

  Widget _item(index) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: ScreenUtil().setHeight(330),
        width: ScreenUtil().setWidth(250),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(width: 1, color: Colors.black12)
          )
        ),
        child: Column(
          children: <Widget>[
            Image.network(recommendList[index]['image']),
            Text('￥${recommendList[index]['mallPrice']}'),
            Text(
              '￥${recommendList[index]['price']}',
              style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }

  Widget _recommendList() {
    return Container(
      height: ScreenUtil().setHeight(330),
      child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: recommendList.length,
      itemBuilder: (context, index) {
        return _item(index);
      },
    ),);
  }
}

class FloorTitle extends StatelessWidget {
  final String picture_address; // 图片地址
  FloorTitle({Key key, this.picture_address}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Image.network(picture_address),
    );
  }
}

class FloorContent extends StatelessWidget {

  final List floorGoodsList;

  FloorContent({Key key, this.floorGoodsList}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: Column(
      children: <Widget>[
        _firstRow(),
        _otherGoods(),
      ],
    ),);
  }

  Widget _firstRow() {
    return Row(children: <Widget>[
      _goodsItem(floorGoodsList[0]),
      Column(
        children: <Widget>[
          _goodsItem(floorGoodsList[1]),
          _goodsItem(floorGoodsList[2]),
        ],
      )
    ],);
  }

  Widget _otherGoods() {
    return Row(children: <Widget>[
      _goodsItem(floorGoodsList[3]),
      _goodsItem(floorGoodsList[4]),
    ],);
  }

  Widget _goodsItem(Map goods) {
    return Container(
      width: ScreenUtil().setWidth(375),
      child: InkWell(
        onTap: () {print('点击了楼层商品');},
        child: Image.network(goods['image']),
      ),
    );
  }
}

