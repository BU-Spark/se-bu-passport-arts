import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:chip_list/chip_list.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class Label extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const Label({
    Key? key,
    required this.text,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.bold,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: fontSize, color: color),
            children: [
              TextSpan(
                text: text,
                style: TextStyle(fontWeight: fontWeight),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class FilterWidget extends StatefulWidget {
  final RangeValues? initRange;
  final Function(RangeValues, List<int>, List<String>, bool, String) onApplyFilters;
  final Function onResetFilters;
  final Function goBackToEvents;
  final HashSet<String> categories;
  //final HashSet<String> locations;
  final List<int> selectedChips;
  final HashSet<String> locations;
  final String selectedLocation;

  FilterWidget({
    required this.onApplyFilters,
    required this.onResetFilters,
    required this.initRange,
    required this.categories,
    required this.goBackToEvents,
    required this.selectedChips,
    required this.locations,
    required this.selectedLocation,
    //required this.locations,
  });

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late RangeValues _currentRangeValues;
  final RangeValues _initialRangeValues = RangeValues(0, 100);
  late List<int> _selectedChips;
  late List<String> _chips;
  final TextEditingController _minPtsController = TextEditingController();
  final TextEditingController _maxPtsController = TextEditingController();
  late List<String> _locations;
  late String _currentLocation;
  late MultiValueDropDownController _cntMulti;
  //List<String> locations = ["1","2","3"];

  @override
  void initState() {
    super.initState();
    // Initialize the range values with the passed initRange
    _currentRangeValues = widget.initRange==null ? _initialRangeValues : widget.initRange!;
    //_initialSelectedChips = [0];
    _chips = widget.categories.toList();
    _chips.insert(0, "All");
    _selectedChips = widget.selectedChips.isEmpty?List.generate(_chips.length, (index) => index):widget.selectedChips;
    _minPtsController.text = _currentRangeValues.start.toInt().toString();
    _maxPtsController.text = _currentRangeValues.end.toInt().toString();
    _locations = widget.locations.toList();
    _locations.insert(0, "All places");
    _currentLocation = widget.selectedLocation;
  }

  void applyFilter(){
    bool filterState = false;
    if(_currentRangeValues.start!=0||
        _currentRangeValues.end!=100||
        (_selectedChips.length!=0&&_selectedChips.length!=_chips.length)||
        _currentLocation!="All places"){
      filterState=true;
    }
    widget.onApplyFilters(_currentRangeValues, _selectedChips, _chips, filterState, _currentLocation);
    //widget.goBackToEvents();
  }

  void invalidPtsToast(){
    print("toase:");
    Fluttertoast.showToast(
      msg: 'Please enter an valid integer.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.03);
    double edgeInsets = (MediaQuery.of(context).size.width * 0.02);
    return Padding(
      padding: EdgeInsets.all(edgeInsets * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Event Filter",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentRangeValues = _initialRangeValues;
                    _selectedChips = List.generate(_chips.length, (index) => index);
                    _minPtsController.text = _currentRangeValues.start.toInt().toString();
                    _maxPtsController.text = _currentRangeValues.end.toInt().toString();
                    _currentLocation = "All places";
                  });
                  widget.onResetFilters();
                  applyFilter();
                },
                child: Text(
                  'Reset all',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )

            ],
          ),
          SizedBox(height: sizedBoxHeight),
          Label(text: "Location"),
          DropdownMenu<String>(
            initialSelection: _currentLocation,
            expandedInsets: EdgeInsets.zero,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            menuStyle: MenuStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
            ),
            dropdownMenuEntries: _locations.map((location) {
              return DropdownMenuEntry<String>(
                value: location,
                label: location,
              );
            }).toList(),
            onSelected: (l){
              if(l!=null){
                _currentLocation=l!;
                applyFilter();
              }

            },
          ),
          SizedBox(height: sizedBoxHeight),
          Label(text: "Pts"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: screenWidth/2.3,
                child: TextField(
                  controller: _minPtsController,
                  decoration: InputDecoration(
                    hintText: _currentRangeValues.start.toString(),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onSubmitted: (pts) {
                    int? value = int.tryParse(pts);

                    if (value == null || value < 0 || value > 100 || value > _currentRangeValues.end) {
                      invalidPtsToast();
                    } else {
                      setState(() {
                        _currentRangeValues = RangeValues(value.toDouble(), _currentRangeValues.end);
                        _minPtsController.text = value.toString(); // Update the text field
                      });
                    }
                  },
                ),
              ),
              Spacer(),
              SizedBox(
                width: screenWidth/2.3, // Adjust the width as needed
                child: TextField(
                  controller: _maxPtsController,
                  decoration: InputDecoration(
                    hintText: _currentRangeValues.end.toString(),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onSubmitted: (pts) {
                    // Try to parse the input and check if it's a valid integer within the range
                    int? value = int.tryParse(pts);

                    if (value == null || value < 0 || value > 100|| value< _currentRangeValues.start) {
                      invalidPtsToast();
                    } else {
                      setState(() {
                        _currentRangeValues = RangeValues(_currentRangeValues.start, value.toDouble());
                        _maxPtsController.text = value.toString();
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: sizedBoxHeight/2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("${_initialRangeValues.start.toInt().toString()}pt",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor
                ),
              ),
              Spacer(),
              Text("${_initialRangeValues.end.toInt().toString()}pt",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor
                ),
              ),
            ],
          ),
          RangeSlider(
            activeColor: Theme.of(context).primaryColor,
            values: _currentRangeValues,
            max: 100,
            divisions: 100,
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
                _minPtsController.text = _currentRangeValues.start.toInt().toString();
                _maxPtsController.text = _currentRangeValues.end.toInt().toString();
              });
              applyFilter();
            },
          ),
          SizedBox(height: sizedBoxHeight),
          Label(text: "Tags"),
          ChipList(
            listOfChipNames: _chips,
            activeBgColorList: [Theme.of(context).primaryColor],
            inactiveBgColorList: [Colors.grey],
            activeTextColorList: [Colors.white],
            inactiveTextColorList: [Colors.white],
            listOfChipIndicesCurrentlySelected: _selectedChips,
            supportsMultiSelect: true,
            shouldWrap: true,
            showCheckmark: false,
            extraOnToggle: (val) {
              //print(val);
              setState(() {
                if(val==0){
                  if(!_selectedChips.contains(0)){
                    _selectedChips = [];
                  }else{
                    _selectedChips = List.generate(_chips.length, (index) => index);
                  }
                }else{
                  if(!_selectedChips.contains(val)){
                    _selectedChips.remove(0);
                  }
                }
              });
              applyFilter();

            },
          ),
          SizedBox(height: sizedBoxHeight),

        ],
      ),
    );
  }
}
