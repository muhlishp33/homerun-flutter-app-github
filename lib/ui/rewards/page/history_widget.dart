import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appid/component/http_service.dart'; 
import 'package:appid/helper/color.dart';

// ignore: must_be_immutable
class HistoryWidget extends StatelessWidget {
  dynamic dataPoin;
  HistoryWidget(this.dataPoin, {super.key});

  HttpService http = HttpService();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dataPoin.length,
        itemBuilder: (context, snap) {
          var datetime = DateTime.parse(dataPoin[snap]['date']);
          var date = DateFormat('dd MMMM yyyy', 'id').format(datetime);
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Hari ini',
                //   style: TextStyle(
                //       color: Colors.black,
                //       fontWeight: FontWeight.w800,
                //       fontSize: 16),
                // ),
                // SizedBox(
                //   height: 8,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: '${dataPoin[snap]['image_url']}',
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Color(0xffee6055),
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: imageProvider,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          placeholder: (context, url) => Image.asset(
                            'assets/images/loader.gif',
                            scale: 14,
                          ),
                          errorWidget: (context, url, error) => Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffee6055),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.error,
                                  color: Colors.white,
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dataPoin[snap]['caption']}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                            ),
                            Text(
                              date,
                              style: const TextStyle(
                                  color: Color(0xff828382),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12),
                            )
                          ],
                        )
                      ],
                    ),
                    Text(
                      '${dataPoin[snap]['value']}',
                      style: TextStyle(
                          color: colorFromHex(
                              dataPoin[snap]["color_value"]),
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }
}
