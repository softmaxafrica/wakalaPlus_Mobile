import 'package:flutter/material.dart';

class Miamala extends StatelessWidget {
  const Miamala({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
     behavior: ScrollBehavior(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 100,width: 150,
                  child: ElevatedButton(
                      onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)
                      )
                    ),
                      child: Text("Weka Pesa"),
                )
                ),
                SizedBox(width: 9,),
                SizedBox(
                    height: 100,width:150,
                    child: ElevatedButton(
                      onPressed: (){},
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9)
                          )
                      ),
                      child: Text("Toa pesa"),
                    )
                )
              ],
            )
          , SizedBox(height: 15,),

            SizedBox(
                height: 50,width: 200,
                child: ElevatedButton(
                  onPressed: (){},
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9)
                      )
                  ),
                  child: Text("Huduma Nyingine"),
                )
            )
          ],
        ),
      ),
    );
     }
}
