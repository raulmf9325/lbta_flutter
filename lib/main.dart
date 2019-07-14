import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:transparent_image/transparent_image.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  var _isLoading = false;
  var _itemCount = 0;
  dynamic videosJson;

  _fetchData() async {
    final url = "https://api.letsbuildthatapp.com/youtube/home_feed";

    final response = await http.get(url);
    final map = json.decode(response.body);

    videosJson = map['videos'];

    setState(() {
      _isLoading = false;
      _itemCount = videosJson.length;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LBTA',
      home: Scaffold(
        appBar: AppBar(
          title: Text('LBTA'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                print("reloading...");
                setState(() {
                  _isLoading = true;
                });
                _fetchData();
              },
            )
          ],
        ),
        body: Center(
            child: (_isLoading)
                ? SpinKitFadingCircle(
                    color: Colors.grey,
                    size: 50.0,
                  )
                : ListView.builder(
                    itemCount: _itemCount,
                    padding: EdgeInsets.all(20.0),
                    itemBuilder: (BuildContext context, int index) {
                      var video = this.videosJson[index];
                      return FlatButton(
                        padding: EdgeInsets.all(20.0),
                        child: Cell(video),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailsPage(index + 1)));
                        },
                      );
                    },
                  )),
      ),
      theme: ThemeData(primarySwatch: Colors.purple),
    );
  }
}

class Cell extends StatelessWidget {
  final video;

  Cell(this.video);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        //Image.network(video['imageUrl']),
        Container(
          height: 200.0,
          width: MediaQuery.of(context).size.width,
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/picture.png',
            image: video['imageUrl'],
            fit: BoxFit.cover,
          ),
        ),
        Container(
          height: 10.0,
        ),
        Text(
          video['name'],
          style: TextStyle(fontSize: 15.0),
        ),
        Container(
          height: 10.0,
        ),
        Divider(),
      ],
    );
  }
}

class DetailsPage extends StatefulWidget {
  final pageNumber;

  DetailsPage(this.pageNumber);

  @override
  State<StatefulWidget> createState() => DetailsPageState(pageNumber);
}

class DetailsPageState extends State<DetailsPage> {
  // stored properties
  var pageNumber;
  final url = 'https://api.letsbuildthatapp.com/youtube/course_detail?id=';
  dynamic lessons;
  var isLoading = true;
  var _itemCount = 0;

  // constructor
  DetailsPageState(this.pageNumber);

  // fetch data from server
  _fetchDetails() async {
    final response = await http.get(url + pageNumber.toString());
    final map = json.decode(response.body);
    lessons = map;

    setState(() {
      _itemCount = lessons.length;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details Page')),
      body: Center(
        child: ListView.builder(
          padding: EdgeInsets.all(20.0),
          itemCount: _itemCount,
          itemBuilder: (context, index) {
            if (index.isEven)
              return DetailsCell(lessons[index]);
            else
              return Divider();
          },
        ),
      ),
    );
  }
}

class DetailsCell extends StatelessWidget {
  final lesson;

  DetailsCell(this.lesson);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
          width: 180,
          child: Image.network(lesson['imageUrl']),
        ),
        Container(
          width: 10,
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
          width: MediaQuery.of(context).size.width - (180 + 10 + 20 + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                lesson['name'],
                style: TextStyle(fontSize: 16.0,),
              ),
              Container(height: 4.0,),
              Text(lesson['duration'],),
              Container(height: 4.0,),
              Text("Episode #" + lesson['number'].toString(), style: TextStyle(fontWeight: FontWeight.bold),)
            ],
          ),
        ),
      ],
    );
  }
}
