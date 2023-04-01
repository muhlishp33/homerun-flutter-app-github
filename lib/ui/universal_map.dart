import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/form/custom_text_input.dart';
import 'package:http/http.dart' as http;
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class UniversalMapPage extends StatefulWidget {
  const UniversalMapPage(this.data, {super.key});
  final dynamic data;

  void showModal({
    double elevation = 1,
    required BuildContext context,
    required Widget modalContent,
    int dataLength = 0,
  }) {
    showModalBottomSheet(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          // log("dataLength = $dataLength");
          return Container(
            padding: EdgeInsets.only(
                bottom: dataLength < 3
                    ? MediaQuery.of(context).viewInsets.bottom
                    : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                modalContent,
              ],
            ),
          );
        });
  }

  @override
  State<UniversalMapPage> createState() => UniversalMapPageState();
}

class UniversalMapPageState extends State<UniversalMapPage> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition initialPosition = CameraPosition(
    // bearing: 192.8334901395799,
    target: LatLng(-6.315942743458345, 106.66170887102388),
    // tilt: 59.440717697143555,
    zoom: 14,
  );

  CameraPosition myLocation = CameraPosition(
    // bearing: 192.8334901395799,
    target: LatLng(-6.315942743458345, 106.66170887102388),
    // tilt: 59.440717697143555,
    zoom: 14,
  );
  TextEditingController search = new TextEditingController();
  TextEditingController newSearch = new TextEditingController();
  GoogleMapController? mapController;
  List places = [];
  bool isLoading = false;
  Timer? _debounce;
  String lastKeyword = "";
  var currentLocation;

  PanelController sc = new PanelController();
  @override
  void initState() {
    _markers.add(
      Marker(
        draggable: true,
        markerId: MarkerId('SomeId'),
        position: initialPosition.target,
      ),
    );
    LatLng initPos = initialPosition.target;
    if (widget.data != null &&
        widget.data['geometry'] != null &&
        widget.data['geometry']['location'] != null) {
      initPos = new LatLng(widget.data['geometry']['location']['lat'],
          widget.data['geometry']['location']['lng']);
    }
    changeMarkerPosition(position: initPos);
    searchNearby();
    // search.addListener(onSearchLocation);
    // newSearch.addListener(onNewSearchLocation);
    super.initState();
  }

  @override
  void dispose() {
    search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void onSearchLocation() {
    if (lastKeyword != search.text) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () {
        // Navigator.pop(context); comment if new body
        searchNearby(isShowModal: true);
      });
    }
    setState(() {
      lastKeyword = search.text;
    });
  }

  void onNewSearchLocation() {
    if (lastKeyword != search.text) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () {
        Navigator.pop(context);
        searchNearby(isShowModal: true);
      });
    }
    setState(() {
      lastKeyword = search.text;
    });
  }

  void toMyLocation(CameraPosition camPos) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(camPos),
    );
  }

  Widget locations() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Column(
        children: [
          LimitedBox(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (int i = 0; i < places.length; i++)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context, places[i]);
                      },
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: Constants.redTheme,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      places[i]['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      places[i]['vicinity'],
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isMarkerClick = false;
  
  void searchNearby(
      {bool isShowModal = false,
      int radius = 10000,
      isFirstOnly = false}
  ) async {
    if (isLoading) return;
    
    setState(() {
      isLoading = true;
    });
    String keyword = "";
    if (search.text.isNotEmpty) {
      keyword = "keyword=${search.text}&";
    }
    String rankOrRadius = "&rankby=distance";
    // if (radius == 10000) {
    //   rankOrRadius = "&radius=$radius";
    // }
    String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?${keyword}location=${myLocation.target.latitude}%2C${myLocation.target.longitude}$rankOrRadius&key=AIzaSyCG6dIwWVDWKc2WEr01XYpcHPVDYeHuaLk';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Access-Control-Allow-Headers': 'Content-Type, Content-Range, Content-Disposition, Content-Description, x-requested-with, x-requested-by',
        "accept": "application/json",
        "Access-Control-Allow-Origin":"*",
      }
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // log('data $data');

      setState(() {
        places = data['results'];
        selectedPlace = null;
        isLoading = false;
        if (isFirstOnly && places.length > 0) {
          places = [places[0]];
        }
      });
    } else {
      setState(() {
        isLoading = false; // 6
      });
      throw Exception('An error occurred getting places nearby');
    }
    if (isShowModal) {
      setState(() {
        sc.open();
      });
      // widget.showModal(
      //   dataLength: places.length,
      //   context: context,
      //   modalContent: markerModalBody(),
      // );
    }
  }

  Widget modalBody() {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: CustomTextInput(
            isHasHint: false,
            placeholder: "Search Location",
            controllerName: search,
            enabled: true,
            isRequired: false,
            onChangeText: () {},
            onEditingComplete: () {},
            onTap: () {},
            errorTextWidget: null,
          ),
        ),
        locations(),
      ]),
    );
  }

  List mapList = [
    MapType.normal,
    MapType.hybrid,
    MapType.hybrid,
    MapType.satellite,
    MapType.terrain
  ];
  int selectedMap = 0;
  List<Marker> _markers = <Marker>[];
  void changeMarkerPosition(
      {required LatLng position, bool showModal = false, bool isFirstOnly = false}) {
    Marker marker = _markers[0];
    setState(() {
      if (isFirstOnly) isMarkerClick = true;
      search.text = "";
      newSearch.text = "";
      _markers[0] = marker.copyWith(positionParam: position);
      myLocation = CameraPosition(
        target: position,
        zoom: 14,
      );
    });
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (showModal)
        searchNearby(isShowModal: true, radius: 10, isFirstOnly: isFirstOnly);
    });
    // if (showModal) {
    //   searchNearby(isShowModal: true);
    // }
  }

  Widget mapWidget() {
    return GoogleMap(
      onCameraMove: (position) {
        // log("position = $position");
        changeMarkerPosition(
            position: position.target, showModal: true, isFirstOnly: true);
      },
      compassEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: true,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      buildingsEnabled: true,
      mapType: mapList[selectedMap],
      markers: Set<Marker>.of(_markers),
      initialCameraPosition: myLocation,
      onTap: (argument) {
        // log("argument = $argument");
        changeMarkerPosition(
            position: argument, showModal: true, isFirstOnly: true);
      },
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  Widget oldBody() {
    return mapWidget();
  }

  double marginBottom = 0;
  void changeMarginBottomSize({double size = 0}) {
    setState(() {
      marginBottom = size;
    });
    if (sc.isPanelOpen) {
      setState(() {
        marginBottom = 0;
      });
    }
    // log("marginBottom = $marginBottom sc = ${sc.isPanelOpen}}");
  }

  dynamic selectedPlace;
  Widget newLocations() {
    if (isMarkerClick && places.length > 0) {
      places = [places[0]];
    }
    
    return GestureDetector(
      onTap: () {
        // log("sini ===================================> uy");
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        margin: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
        ),
        child: Column(
          children: [
            LimitedBox(
              maxHeight: MediaQuery.of(context).size.height *
                  (isMarkerClick ? 0.25 : 0.75),
              child: Container(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 0),
                        children: [
                          for (int i = 0; i < places.length; i++)
                            Container(
                              decoration: BoxDecoration(
                                color: (selectedPlace != null &&
                                        selectedPlace == places[i])
                                    ? Constants.redTheme
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedPlace = places[i];
                                  });

                                  if (places[i] != null &&
                                      places[i]['geometry'] != null &&
                                      places[i]['geometry']['location'] != null
                                  ) {
                                    LatLng initPos = LatLng(places[i]['geometry']['location']['lat'],
                                        places[i]['geometry']['location']['lng']);
                                    changeMarkerPosition(position: initPos);

                                    final CameraPosition camPos = CameraPosition(
                                      target: initPos,
                                      zoom: 14,
                                    );
                                    toMyLocation(camPos);
                                  }
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text(
                                                places[i]['name'] ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color:
                                                      (selectedPlace != null &&
                                                              selectedPlace ==
                                                                  places[i])
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                places[i]['vicinity'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      (selectedPlace != null &&
                                                              selectedPlace ==
                                                                  places[i])
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Container(
                                    //   margin: EdgeInsets.only(left: 10),
                                    //   padding: EdgeInsets.symmetric(
                                    //       horizontal: 10, vertical: 10),
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.grey.shade300,
                                    //     borderRadius: BorderRadius.circular(50),
                                    //   ),
                                    //   child: Icon(
                                    //     Icons.location_on_outlined,
                                    //     color: Constants.redTheme,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: InkWell(
                              onTap: () {
                                if (selectedPlace != null)
                                  Navigator.pop(context, selectedPlace);
                                if (selectedPlace == null)
                                  Navigator.pop(context, places[0]);

                                // if (isMarkerClick && places.length > 0)
                                //   Navigator.pop(context, places[0]);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Constants.redTheme,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Next",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          (!isMarkerClick)
                              ? Container(
                                  child: InkWell(
                                    onTap: () {
                                      sc.close();
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Constants.redTheme,
                                        ),
                                      ),
                                      child: Text(
                                        "Pilih pada peta",
                                        style: TextStyle(
                                          color: Constants.redTheme,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        isMarkerClick = false;
                                      });
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Constants.redTheme,
                                        ),
                                      ),
                                      child: Text(
                                        "Back",
                                        style: TextStyle(
                                          color: Constants.redTheme,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget panelBody() {
    return Container(
      margin: EdgeInsets.only(
        top: 30,
      ),
      child: Column(
        children: [
          if (!isMarkerClick) searchDefault(),
          newLocations(),
        ],
      ),
    );
  }

  Widget searchDefault({Function? onTap}) {
    return Container(
      margin: EdgeInsets.only(right: 20, left: 20),
      child: InkWell(
        onTap: () {
          if (onTap != null) onTap();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomTextInput(
                isHasHint: false,
                placeholder: "Search Location",
                controllerName: search,
                enabled: true,
                isRequired: false,
                onChangeText: () {},
                onTap: () {
                  if (onTap != null) onTap();
                },
                onEditingComplete: () {},
                errorTextWidget: null,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: InkWell(
                onTap: () {
                  if (onTap != null) {
                    onTap();
                  } else {
                    searchNearby(isShowModal: true);
                  }
                },
                child: Container(
                  child: Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                      color: Constants.redTheme,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget newBody() {
    return Stack(
      children: [
        SlidingUpPanel(
          controller: sc,
          isDraggable: true,
          margin: EdgeInsets.only(
            bottom: marginBottom,
          ),
          onPanelOpened: () {
            // log("open");
            changeMarginBottomSize(size: 0);
          },
          onPanelClosed: () {
            changeMarginBottomSize(size: 0);
            // log("close");
          },
          onPanelSlide: (position) {
            // log("slide $position");
          },
          collapsed: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  searchDefault(
                    onTap: () {
                      sc.open();
                    },
                  ),
                ],
              ),
            ),
          ),
          panel: panelBody(),
          maxHeight: isMarkerClick
              ? MediaQuery.of(context).size.height * 0.3
              : MediaQuery.of(context).size.height * 0.9,
          body: mapWidget(),
        ),
        // Positioned(
        //   right: 10,
        //   top: 100,
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.circular(50),
        //     ),
        //     child: IconButton(
        //       color: Colors.black,
        //       onPressed: () {
        //         toMyLocation();
        //       },
        //       icon: Icon(
        //         Icons.my_location_rounded,
        //       ),
        //     ),
        //   ),
        // )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // log("widget.data = ${widget.data}");

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: InkWell(
          child: Icon(Icons.chevron_left),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Pin Location",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: LoadingFallback(
        isLoading: isLoading,
        child: newBody(),
      ),
    );
  }
}
