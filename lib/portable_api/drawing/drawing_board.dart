import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:love_code/ui/util/lc_dialog.dart';
import 'package:popover/popover.dart';

class IzDrawingBoard extends StatefulWidget {
  const IzDrawingBoard(
      {super.key,
      required this.width,
      required this.height,
      required this.background,
      required this.controller});
  final double width;
  final double height;
  final Color background;
  final DrawingController controller;

  @override
  State<IzDrawingBoard> createState() => _IzDrawingBoardState();
}

class _IzDrawingBoardState extends State<IzDrawingBoard> {
  late Color selectedColor;
  @override
  void initState() {
    selectedColor = Colors.black;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DrawingBoard(
        defaultToolsBuilder: (type, controller) {
          return DrawingBoard.defaultTools(type, controller)
            ..insert(
              1,
              DefToolItem(
                icon: Icons.square,
                color: controller.getColor,
                isActive: false,
                onTap: () async => await showLcDialog(
                    barrierDismissible: true,
                    height: MediaQuery.of(context).size.height * 0.8,
                    body: ColorPicker(
                        pickerColor: Colors.red,
                        onColorChanged: (c) {
                          setState(() {
                            selectedColor = c;
                            controller.setStyle(color: c);
                          });
                        })),
              ),
            );
        },
        background: Container(
            width: widget.width,
            height: widget.height,
            color: widget.background),
        showDefaultTools: true,
        showDefaultActions: true,
        controller: widget.controller,
      ),
    );
  }
}
