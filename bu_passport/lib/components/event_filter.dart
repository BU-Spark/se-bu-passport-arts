import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:chip_list/chip_list.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FilterWidget extends StatefulWidget {
  final RangeValues initRange;
  final Function(RangeValues, List<int>, List<String>) onApplyFilters;
  final Function onResetFilters;
  final Function goBackToEvents;
  final HashSet<String> categories;
  final List<int> selectedChips;

  FilterWidget({
    required this.onApplyFilters,
    required this.onResetFilters,
    required this.initRange,
    required this.categories,
    required this.goBackToEvents,
    required this.selectedChips,
  });

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late RangeValues _currentRangeValues;
  RangeValues _initialRangeValues = RangeValues(0, 100);
  late List<int> _selectedChips;
  late List<String> _chips;
  final TextEditingController _minPtsController = TextEditingController();
  final TextEditingController _maxPtsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the range values with the passed initRange
    _currentRangeValues = widget.initRange;
    //_initialSelectedChips = [0];
    _chips = widget.categories.toList();
    _chips.insert(0, "All");
    _selectedChips = widget.selectedChips.isEmpty?List.generate(_chips.length, (index) => index):widget.selectedChips;
    _minPtsController.text = _currentRangeValues.start.toInt().toString();
    _maxPtsController.text = _currentRangeValues.end.toInt().toString();
  }

  void applyFilter(){
    widget.onApplyFilters(_currentRangeValues, _selectedChips, _chips);
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
    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.02);
    double edgeInsets = (MediaQuery.of(context).size.width * 0.02);
    return Padding(
      padding: EdgeInsets.all(edgeInsets * 2),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Event Filter",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: sizedBoxHeight),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Pts: \n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //SizedBox(width: screenWidth/30,),
                  // First TextField on the left
                  SizedBox(
                    width: screenWidth/2.5, // Adjust the width as needed
                    child: TextField(
                      controller: _minPtsController,
                      decoration: InputDecoration(
                        hintText: _currentRangeValues.start.toString(),
                        filled: true,
                        fillColor: Colors.white, // Background color for a box effect
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0), // Rounded box shape
                          //borderSide: BorderSide(color: Colors.red, width: 0.7), // Light grey border
                        ),
                      ),
                      onSubmitted: (pts) {
                        // Try to parse the input and check if it's a valid integer within the range
                        int? value = int.tryParse(pts);

                        if (value == null || value < 0 || value > 100 || value > _currentRangeValues.end) {
                          // If the value is invalid, show a toast message
                          invalidPtsToast();
                        } else {
                          // If the value is valid, update the RangeValues
                          setState(() {
                            _currentRangeValues = RangeValues(value.toDouble(), _currentRangeValues.end);
                            _minPtsController.text = value.toString(); // Update the text field
                          });
                        }
                      },
                    ),
                  ),
                  // Spacer for space between the TextFields
                  Spacer(),
                  // Second TextField on the right
                  SizedBox(
                    width: screenWidth/2.5, // Adjust the width as needed
                    child: TextField(
                      controller: _maxPtsController,
                      decoration: InputDecoration(
                        hintText: _currentRangeValues.end.toString(),
                        filled: true,
                        fillColor: Colors.white, // Background color for a box effect
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0), // Rounded box shape
                          //borderSide: BorderSide(color: Colors.red, width: 0.7), // Light grey border
                        ),
                      ),
                      onSubmitted: (pts) {
                        // Try to parse the input and check if it's a valid integer within the range
                        int? value = int.tryParse(pts);

                        if (value == null || value < 0 || value > 100|| value< _currentRangeValues.start) {
                          // If the value is invalid, show a toast message
                          invalidPtsToast();
                        } else {
                          // If the value is valid, update the RangeValues
                          setState(() {
                            _currentRangeValues = RangeValues(_currentRangeValues.start, value.toDouble());
                            _maxPtsController.text = value.toString(); // Update the text field
                          });
                        }
                      },
                    ),
                  ),
                  //SizedBox(width: screenWidth/30,),
                ],
              ),
              SizedBox(height: sizedBoxHeight),

              RangeSlider(
                values: _currentRangeValues,
                max: 100,
                divisions: 100,
                // labels: RangeLabels(
                //   _currentRangeValues.start.round().toString(),
                //   _currentRangeValues.end.round().toString(),
                // ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentRangeValues = values;
                    _minPtsController.text = _currentRangeValues.start.toInt().toString();
                    _maxPtsController.text = _currentRangeValues.end.toInt().toString();
                  });
                  applyFilter();
                  //widget.onRangeChanged(values); // Inform parent of range change
                },
              ),
              SizedBox(height: sizedBoxHeight),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Tags: \n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ChipList(
                listOfChipNames: _chips,
                activeBgColorList: [Theme.of(context).primaryColor],
                inactiveBgColorList: [Colors.white],
                activeTextColorList: [Colors.white],
                inactiveTextColorList: [Theme.of(context).primaryColor],
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
                    }
                  });
                  applyFilter();

                },
                //borderColorList: [Theme.of(context).primaryColor],
              ),
              // ElevatedButton(
              //   onPressed: (){
              //     //TODO: add selected categories
              //     applyFilter();
              //   }, // Apply filter logic
              //   child: Text('Apply Filters'),
              // ),
            ],
          ),

          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentRangeValues = _initialRangeValues; // Reset slider values
                    _selectedChips = List.generate(_chips.length, (index) => index);
                    _minPtsController.text = _currentRangeValues.start.toInt().toString();
                    _maxPtsController.text = _currentRangeValues.end.toInt().toString();
                  });
                  widget.onResetFilters(); // Notify parent for reset action
                  applyFilter();
                  //TODO: Does resetting automatically leads to applying?
                },
                child: Text('Reset'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(80, 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
