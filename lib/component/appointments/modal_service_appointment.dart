import 'package:flutter/material.dart';

import 'package:appid/component/widget/constants.dart';

class ModalServiceAppointment extends StatefulWidget {
  const ModalServiceAppointment(
      {super.key,
      required this.data,
      required this.onTapString,
      required this.appointmentType});

  final List<dynamic> data;
  final String onTapString;
  final String appointmentType;
  @override
  State<ModalServiceAppointment> createState() =>
      _ModalServiceAppointmentState();
}

class _ModalServiceAppointmentState extends State<ModalServiceAppointment> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ('widget ${widget.data}');

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 36,
            child: Center(
              child: Container(
                height: 3,
                width: MediaQuery.of(context).size.width / 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.5),
                  color: Constants.colorBorder,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
            child: const Text(
              'Our Services',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            // height: MediaQuery.of(context).size.height * 0.75,
            // padding: const EdgeInsets.only(
            //     bottom: MediaQuery.of(context).viewPadding.bottom),
            // color: Colors.white,
            child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: _buildListServices(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListServices() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.data.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);

              Navigator.of(context).pushNamed(widget.onTapString, arguments: {
                ...widget.data[index],
                'appointmentType': widget.appointmentType,
              });
            },
            child: Card(
              elevation: 0,
              // margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                leading: Container(
                  height: MediaQuery.of(context).size.width * 0.1,
                  width: MediaQuery.of(context).size.width * 0.1,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFF2F2F6)),
                  child: Center(
                    child: widget.data[index]['service_image'] == null ||
                            widget.data[index]['service_image'] == ''
                        ? const SizedBox()
                        : Image(
                            image: NetworkImage(
                                widget.data[index]['service_image']),
                            fit: BoxFit.contain,
                            height: MediaQuery.of(context).size.width * 0.075,
                            width: MediaQuery.of(context).size.width * 0.075,
                          ),
                  ),
                ),
                title: Text(widget.data[index]['service_name'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    )),
                subtitle: Column(
                  children: [
                    if (widget.data[index]['service_day'] != null)
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: Text(widget.data[index]['service_day'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFA1A4B2),
                            )),
                      ),
                    Container(
                      alignment: Alignment.bottomLeft,
                      child: Text(widget.data[index]['service_desc'] ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA1A4B2),
                          )),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          );
        });
  }
}
