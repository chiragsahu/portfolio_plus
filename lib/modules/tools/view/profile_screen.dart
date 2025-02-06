import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:portfolio_plus/components/custom_app_bar.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  final List<ToolsModel> tools = [
    ToolsModel(name: 'Mutual Fund Compare Tool', icon: Icons.ac_unit),
    ToolsModel(name: 'Tool 2', icon: Icons.access_alarm),
    ToolsModel(name: 'Tool 3', icon: Icons.access_time),
    ToolsModel(name: 'Tool 4', icon: Icons.accessibility),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Financial Tools'),
      body: Column(
        children: [
          8.height,
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: tools.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(12),
                  backgroundColor: Colors.grey.withOpacity(0.1),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(tools[index].icon, size: 30),
                      8.height,
                      Text(
                        tools[index].name,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// tools model with name and icon
class ToolsModel {
  final String name;
  final IconData icon;

  ToolsModel({required this.name, required this.icon});
}
