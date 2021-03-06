import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crud_operations.dart';
import 'convertidor.dart';
import 'insert.dart';
import 'delete.dart';
import 'profile.dart';
import 'select.dart';
import 'students.dart';
import 'dart:async';

import 'update_table.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData(brightness: Brightness.light, primarySwatch: Colors.lightGreen),
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.lightGreen),
      debugShowCheckedModeBanner: false,
      home: Insert(),
    );
  }
}

class Insert extends StatefulWidget {
  @override
  _myInsert createState() => new _myInsert();
}

class _myInsert extends State<Insert> {
  // VAR MANEJO BD
  Future<List<Student>> Students;
  TextEditingController controllerN = TextEditingController();
  TextEditingController controllerAP = TextEditingController();
  TextEditingController controllerAPP = TextEditingController();
  TextEditingController controllerTE = TextEditingController();
  TextEditingController controllerC = TextEditingController();
  TextEditingController controllerM = TextEditingController();
  TextEditingController controllerI = TextEditingController();

  int currentUserId;
  String photo;
  String name;
  String app;
  String appP;
  String telef;
  String correo;
  String matricula;

  final formkey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var dbHelper;
  bool isUpdating;


  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }

  void refreshList() {
    setState(() {
      Students = dbHelper.getStudents();
    });
  }

  void cleanData() {
    controllerM.text = "";
    controllerAPP.text = "";
    controllerAP.text = "";
    controllerTE.text = "";
    controllerC.text = "";
    controllerN.text = "";
    controllerI.text = "";
  }

  void dataValidate() async {
    if (formkey.currentState.validate()) {
      formkey.currentState.save();
      if(photo == '' || photo == null){
        final snackBar = SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text('Una imagen es requerida'),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }else{
        if (isUpdating) {
          Student stu = Student(currentUserId, photo, name, app, appP, telef, correo, matricula);
          setState(() {
            isUpdating = false;
          });
        } else {
          Student stu = Student(null, photo, name, app, appP, telef, correo, matricula);
          var validation = await dbHelper.validateInsert(stu);
          print(validation);
          if (validation) {
            print(photo);
            dbHelper.insert(stu);
            final snackBar = SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text('Insertado, puedes verificarlo en Perfiles, recuerda que tambien puedes modificar ahi la imagen'),
            );
            _scaffoldKey.currentState.showSnackBar(snackBar);
          } else{
            final snackBar = SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text('Lo siento esa matricula ya le pertenece a otro alumno'),
            );
            _scaffoldKey.currentState.showSnackBar(snackBar);
          }
        }

        cleanData();
        refreshList();
      }

    }
  }

  pickImagefromGallery(){
    ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 480, maxWidth: 640).then((imgFile){
      if(imgFile != null){
        String imgString = Convertir.base64String(imgFile.readAsBytesSync());
        setState(() {
          photo= imgString;
        });
        return imgString;
      }else{
        Fluttertoast.showToast(msg: "No seleccionó ninguna fotografía");
        return null;
      }
    });
  }

  pickImagefromCamara(){
    ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 480, maxWidth: 640).then((imgFile){
      if(imgFile != null){
        String imgString = Convertir.base64String(imgFile.readAsBytesSync());
        setState(() {
          photo= imgString;
          print(photo);
        });
        return imgString;
      }else{
        Fluttertoast.showToast(msg: "No se capturó ninguna una fotografía");
        return null;
      }
    });
  }


  // FORMULARIO

  Widget form() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(left: 35, right: 35, top: 0),
        child: SingleChildScrollView(
          child: Container(
            child: Form(
              key: formkey,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0, left: 90.0, right: 90.0, bottom: 20.0),
                        child: Center(
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.camera),
                                onPressed: (){
                                  pickImagefromCamara();
                                },),
                              IconButton(
                                icon: Icon(Icons.photo),
                                onPressed: (){
                                  pickImagefromGallery();
                                },),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      cursorColor: Colors.green,
                      cursorRadius: Radius.circular(10.0),
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                      cursorWidth: 5.0,
                      controller: controllerN,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: "Nombre"),
                      validator: (val) => val.length == 0 ? 'Llena el campo' : null,
                      onSaved: (val) => name = val,
                    ),

                    new SizedBox(height: 10.0),
                    TextFormField(
                      cursorColor: Colors.green,
                      cursorRadius: Radius.circular(10.0),
                      cursorWidth: 5.0,
                      controller: controllerAPP,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                      decoration: InputDecoration(labelText: "Apellido Materno"),
                      validator: (val) => val.length == 0 ? 'Llena el campo' : null,
                      onSaved: (val) => app = val.toUpperCase().toString(),
                    ),

                    new SizedBox(height: 10.0),
                    TextFormField(
                      cursorColor: Colors.green,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                      cursorRadius: Radius.circular(10.0),
                      cursorWidth: 5.0,
                      controller: controllerAP,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: "Apellido Paterno"),
                      validator: (val) => val.length == 0 ? 'Llena el campo' : null,
                      onSaved: (val) => appP = val.toString(),
                    ),

                    new SizedBox(height: 5.0),
                    TextFormField(
                      cursorColor: Colors.green,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.w300),
                      cursorRadius: Radius.circular(10.0),
                      cursorWidth: 5.0,
                      controller: controllerTE,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Telefono"),
                      validator: (val) => val.length == 0 || val.contains(',') ? 'Por favor, verifica este campo' : null,
                      onSaved: (val) => telef = val.toString(),
                    ),

                    new SizedBox(height: 5.0),
                    TextFormField(
                      cursorColor: Colors.green,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                      cursorRadius: Radius.circular(10.0),
                      cursorWidth: 5.0,
                      controller: controllerC,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: "Correo"),
                      validator: (val) => val.length == 0 || !val.contains('@') || !val.contains('.') ? 'Por favor, verifica este campo' : null,
                      onSaved: (val) => correo = val.toString(),
                    ),

                    new SizedBox(height: 5.0),
                    TextFormField(
                      cursorColor: Colors.green,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                      cursorRadius: Radius.circular(10.0),
                      cursorWidth: 5.0,
                      controller: controllerM,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Matricula"),
                      validator: (val) => val.length == 0 ? 'Por favor, verifica este campo' : null,
                      onSaved: (val) => matricula = val.toString(),
                    ),

                    SizedBox(height: 30),
                    SingleChildScrollView(
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.greenAccent),
                            ),
                            onPressed: dataValidate,
                            child: Text(isUpdating ? 'Insert' : 'Save'),
                          ),
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.greenAccent),
                            ),
                            onPressed: () {
                              setState(() {
                                isUpdating = false;
                              });
                              cleanData();
                            },
                            child: Text("Cancel"),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key:_scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Bienvenido',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  image: NetworkImage("https://i.pinimg.com/564x/c6/ba/ed/c6baed10c25ed570e5fa47cf709796d8.jpg"),
                ),
                color: Colors.white,
              ),
            ),
            ListTile(
              leading: Icon(Icons.assignment, color: Colors.yellow[800]),
              title: Text('Perfiles'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => DetailScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.add, color: Colors.yellow[800]),
              title: Text('Insert'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Insert()));
              },
            ),
            ListTile(
              title: Text('Update'),
              leading: Icon(Icons.update, color: Colors.yellow[800]),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => UpdateData()));
              },
            ),
            ListTile(
              title: Text('Delete'),
              leading: Icon(Icons.delete, color: Colors.yellow[800]),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Delete()));
              },
            ),
            ListTile(
              leading: Icon(Icons.search, color: Colors.yellow[800]),
              title: Text('Select'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Search()));
              },
            ),
          ],
        ),
      ),

      appBar: new AppBar(
        backgroundColor: Colors.black,
        title: Text('Insercion'),
      ),
      body: new Container(
        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            form(),
          ],
        ),
      ),
    );
  }
}