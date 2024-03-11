import 'package:flutter/material.dart';

class SearchFieldWidget {
  static Widget searchWidget({
    @required TextEditingController searchController,
    @required var baseColor,
    @required bool autoFocus,
    @required bool keyBoardDisable,
    @required var onTap,
    @required var onChanged,
    @required String lable,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onTap,
          ),
          Expanded(
            child: TextField(
              onTap: onTap,
              onChanged: onChanged ??
                  (value) {
                    return null;
                  },
              autofocus: autoFocus,
              showCursor: keyBoardDisable ? false : true,
              readOnly: keyBoardDisable,
              controller: searchController,
              decoration: InputDecoration(
                hintText: lable,
                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                border: InputBorder.none,
              ),
              // onSubmitted: (_) => _performSearch(),
            ),
          ),
        ],
      ),
    );
  }
}
