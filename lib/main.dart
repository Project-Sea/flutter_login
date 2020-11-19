import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_login/data/models/auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:persist_theme/persist_theme.dart';
import 'package:provider/provider.dart';

import 'ui/lockedscreen/home.dart';
import 'ui/lockedscreen/settings.dart';
import 'ui/signin/newaccount.dart';
import 'ui/signin/signin.dart';

void main() => runApp(MaterialApp(title: "GraphQL Client", home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeModel _model = ThemeModel();
  final AuthModel _auth = AuthModel();

  @override
  void initState() {
    try {
      _auth.loadSettings();
    } catch (e) {
      print("Error Loading Settings: $e");
    }
    try {
      _model.init();
    } catch (e) {
      print("Error Loading Theme: $e");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: HttpLink(uri: 'http://jys2erver.site/graphql'),
      ),
    );
    return GraphQLProvider(child: Member(), client: client);
    // return MultiProvider(
    //     providers: [
    //       ChangeNotifierProvider<ThemeModel>.value(value: _model),
    //       ChangeNotifierProvider<AuthModel>.value(value: _auth),
    //       Provider<ValueNotifier<GraphQLClient>>.value(value: client),
    //     ],
    //     child: Consumer<ThemeModel>(
    //       builder: (context, model, child) => MaterialApp(
    //         debugShowCheckedModeBanner: false,
    //         theme: model.theme,
    //         home: Consumer<AuthModel>(builder: (context, model, child) {
    //           if (model?.user != null) return Home();
    //           return LoginPage();
    //         }),
    //         routes: <String, WidgetBuilder>{
    //           "/login": (BuildContext context) => LoginPage(),
    //           "/menu": (BuildContext context) => Home(),
    //           "/home": (BuildContext context) => Home(),
    //           "/settings": (BuildContext context) => SettingsPage(),
    //           "/create": (BuildContext context) => CreateAccount(),
    //         },
    //       ),
    //     ));
  }
}

class Member extends StatefulWidget {
  @override
  _MemeberState createState() => _MemeberState();
}

class _MemeberState extends State<Member> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GraphQL Member")),
      body: Mutation(
        options: MutationOptions(
          documentNode: gql("""
              mutation(\$nickname: String!, \$username: String!, \$password: String!){
                signUp(username: \$username, nickname: \$nickname, password: \$password) {
                  username
                }
              }
          """),
        ),
        builder: (
          RunMutation runMutation,
          QueryResult queryResult,
        ) {
          return Column(
            children: [
              Text('닉네임'),
              TextField(
                decoration: InputDecoration(hintText: 'Nickname'),
                controller: nicknameController,
              ),
              Text('유저ID'),
              TextField(
                decoration: InputDecoration(hintText: 'Username'),
                controller: usernameController,
              ),
              Text('비밀번호'),
              TextField(
                decoration: InputDecoration(hintText: 'Password'),
                controller: passwordController,
              ),
              RaisedButton(
                child: Text('회원가입'),
                onPressed: () {
                  runMutation(
                    {
                      'nickname': nicknameController.text,
                      'username': usernameController.text,
                      'password': passwordController.text,
                    },
                  );
                },
              ),
              Text("Error : ${queryResult.exception.toString()}"),
              Text("Result : ${queryResult.data}"),
            ],
          );
        },
      ),
      // body: Mutation(
      //   options: MutationOptions(
      //     documentNode: gql("""
      //       mutation(\$username: String!, \$password: String!){
      //         signIn(username: \$username, password: \$password,
      //           scopes: ["board_read", "board_write", "notification_read", "project_read", "project_write", "team_read"]) {
      //           access_token,
      //           scope
      //         }
      //       }
      //       mutation(\$id: Float!){
      //         joinTeam(id: \$id) {
      //           access_token,
      //           scope
      //         }
      //       }
      //     """),
      //     onCompleted: (dynamic resultData) {
      //       print("result : $resultData");
      //     },
      //   ),
      //   builder: (
      //     RunMutation runMutation,
      //     QueryResult result,
      //   ) {
      //     return Column(
      //       children: [
      //         TextField(
      //           decoration: InputDecoration(
      //             hintText: "Username",
      //           ),
      //           controller: usernameController,
      //         ),
      //         TextField(
      //           decoration: InputDecoration(
      //             hintText: "Password",
      //           ),
      //           controller: passwordController,
      //         ),
      //         RaisedButton(
      //             child: Text("Submit"),
      //             onPressed: () => {
      //                   runMutation({
      //                     "username": usernameController.text,
      //                     "password": passwordController.text
      //                   })
      //                 }),
      //         Text("Error : ${result.exception.toString()}"),
      //         Text("Result : ${result.data}")
      //       ],
      //     );
      //   },
      // ),
      //   body: Query(
      //     options: QueryOptions(documentNode: gql("""
      //       query {
      //         myProfile {
      //           username,
      //           nickname
      //         }
      //   }
      // """)),
      //     builder: (QueryResult result,
      //         {VoidCallback refetch, FetchMore fetchMore}) {
      //       if (result.exception != null) {
      //         return Center(
      //             child: Text("에러가 발생했습니다.\n${result.exception.toString()}"));
      //       }
      //       if (result.loading) {
      //         return Center(
      //           child: CircularProgressIndicator(),
      //         );
      //       } else {
      //         print(result.data.toString());
      //         return Text(result.data);
      //       }
      //     },)
    );
  }
}
