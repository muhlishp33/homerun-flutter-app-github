import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerRewards extends StatelessWidget {
  const ShimmerRewards({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 1000),
      baseColor: const Color(0xffD8D8D8),
      highlightColor: const Color(0xffc4c4c4),
      enabled: true,
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Shimmer.fromColors(
            period: const Duration(milliseconds: 1000),
            baseColor: const Color(0xffD8D8D8),
            highlightColor: const Color(0xffc4c4c4),
            enabled: true,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 186,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, snap) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20, right: 30),
                    child: Shimmer.fromColors(
                      period: const Duration(milliseconds: 1000),
                      baseColor: const Color(0xffD8D8D8),
                      highlightColor: const Color(0xffc4c4c4),
                      enabled: true,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.87,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white)),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.grey[200],
                                          radius: 50,
                                          child: const FaIcon(
                                              FontAwesomeIcons.userLarge,
                                              color: Constants.redTheme),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Shimmer.fromColors(
                                            period: const Duration(
                                                milliseconds: 1000),
                                            baseColor: const Color(0xffD8D8D8),
                                            highlightColor:
                                                const Color(0xffc4c4c4),
                                            enabled: true,
                                            child: Container(
                                              width: 100,
                                              height: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Shimmer.fromColors(
                                            period: const Duration(
                                                milliseconds: 1000),
                                            baseColor: const Color(0xffD8D8D8),
                                            highlightColor:
                                                const Color(0xffc4c4c4),
                                            enabled: true,
                                            child: Container(
                                              width: 140,
                                              height: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                    padding: const EdgeInsets.all(6),
                                    child: Image.asset(
                                        'assets/images/icon/medal_basic.png'),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 19,
                              ),
                              Shimmer.fromColors(
                                period: const Duration(milliseconds: 1000),
                                baseColor: const Color(0xffD8D8D8),
                                highlightColor: const Color(0xffc4c4c4),
                                enabled: true,
                                child: Container(
                                  width: 50,
                                  height: 10,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Shimmer.fromColors(
                                      period:
                                          const Duration(milliseconds: 1000),
                                      baseColor: const Color(0xffD8D8D8),
                                      highlightColor: const Color(0xffc4c4c4),
                                      enabled: true,
                                      child: Container(
                                        width: 90,
                                        height: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Shimmer.fromColors(
                                    period: const Duration(milliseconds: 1000),
                                    baseColor: const Color(0xffD8D8D8),
                                    highlightColor: const Color(0xffc4c4c4),
                                    enabled: true,
                                    child: Container(
                                      width: 50,
                                      height: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: const Text(
                                    ' ',
                                    //'data["detail_rank"]["progress_label"]',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Shimmer.fromColors(
              period: const Duration(milliseconds: 1000),
              baseColor: const Color(0xffD8D8D8),
              highlightColor: const Color(0xffc4c4c4),
              enabled: true,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, snap) {
                    return Column(children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color(0xffee6055)),
                            padding: const EdgeInsets.all(6),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Shimmer.fromColors(
                                  period: const Duration(milliseconds: 1000),
                                  baseColor: const Color(0xffD8D8D8),
                                  highlightColor: const Color(0xffc4c4c4),
                                  enabled: true,
                                  child: Container(
                                    width: 50,
                                    height: 10,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Shimmer.fromColors(
                                  period: const Duration(milliseconds: 1000),
                                  baseColor: const Color(0xffD8D8D8),
                                  highlightColor: const Color(0xffc4c4c4),
                                  enabled: true,
                                  child: Container(
                                    width: 150,
                                    height: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                    ]);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  period: const Duration(milliseconds: 1000),
                  baseColor: const Color(0xffD8D8D8),
                  highlightColor: const Color(0xffc4c4c4),
                  enabled: true,
                  child: Container(
                    width: 50,
                    height: 10,
                    color: Colors.white,
                  ),
                ),
                Shimmer.fromColors(
                  period: const Duration(milliseconds: 1000),
                  baseColor: const Color(0xffD8D8D8),
                  highlightColor: const Color(0xffc4c4c4),
                  enabled: true,
                  child: Container(
                    width: 50,
                    height: 10,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Shimmer.fromColors(
              period: const Duration(milliseconds: 1000),
              baseColor: const Color(0xffD8D8D8),
              highlightColor: const Color(0xffc4c4c4),
              enabled: true,
              child: Container(
                height: 100,
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, snap) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  period: const Duration(milliseconds: 1000),
                  baseColor: const Color(0xffD8D8D8),
                  highlightColor: const Color(0xffc4c4c4),
                  enabled: true,
                  child: Container(
                    width: 50,
                    height: 10,
                    color: Colors.white,
                  ),
                ),
                Shimmer.fromColors(
                  period: const Duration(milliseconds: 1000),
                  baseColor: const Color(0xffD8D8D8),
                  highlightColor: const Color(0xffc4c4c4),
                  enabled: true,
                  child: Container(
                    width: 50,
                    height: 10,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Shimmer.fromColors(
              period: const Duration(milliseconds: 1000),
              baseColor: const Color(0xffD8D8D8),
              highlightColor: const Color(0xffc4c4c4),
              enabled: true,
              child: Container(
                height: 100,
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, snap) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
