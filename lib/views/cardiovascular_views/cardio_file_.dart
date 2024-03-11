// import 'package:file_manager/app/shared_components/file_type_icon.dart';
// import 'package:file_manager/app/utils/helpers/app_helpers.dart';
// import 'package:filesize/filesize.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
//
// class FileDetail {
//   final String name;
//   final int size;
//
//   const FileDetail({
//      this.name,
//      this.size,
//   });
// }

class FileListButton extends StatelessWidget {
  FileListButton({this.vitalName, this.vitalValue, this.vitalStatus, this.notAvailableKeyLength, this.unit});
  final vitalName;
  final vitalValue;
  final vitalStatus;
  final unit;
  final notAvailableKeyLength;

  // final FileDetail data;
  // final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: Colors.white,
      child: ListTile(
        leading: Icon(Icons.verified_rounded,
          color: vitalValue!='null'&&vitalValue!=''&&vitalValue!=' -'&&notAvailableKeyLength==0
            ?Colors.green.shade400:Colors.grey,),
        // title: Text(
        //   vitalName.toString()??
        //   '  -- ',
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        // ),
        // trailing: Text(
        //   vitalValue.toString()??
        //       '  -- ',
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        // ),
        title: Row(
          children: [
            Text(
              vitalName.toString()??
                  '  -- ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),
            Row(
              children: [
                Text(
                    vitalValue!='null'&&vitalValue!=''&&vitalValue!=' -' ?vitalValue.toString(): '  -- ',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,

                ),
                Text(
                  (vitalValue!='null'&&vitalValue!=''&&vitalValue!=' -')&&(unit!='null'&&unit!=''&&unit!=' -') ?unit.toString(): '',
                  maxLines: 2,
                  style: TextStyle(),
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,

                ),
              ],
            ),

          ],
        ),
        subtitle: Text(
          vitalStatus.toString()=='null'?'':vitalStatus,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        // trailing: IconButton(
        //   onPressed: () {},
        //   icon: Icon(Icons.more_vert_outlined),
        //   tooltip: "more",
        // ),
      ),
    );
  }
}