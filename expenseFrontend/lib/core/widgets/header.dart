// import 'package:flutter/material.dart';

// class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
//   const HomeHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       elevation: 2,
//       title: const Text(
//         "MoneyTracker",
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),

//       centerTitle: false,

//       // Menu à gauche
//       leading: IconButton(
//         icon: const Icon(Icons.menu),
//         onPressed: () {
//           Scaffold.of(context).openDrawer();
//         },
//       ),

//       // Actions à droite
//       actions: [
//         // Notification
//         Stack(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.notifications),
//               onPressed: () {
//               },
//             ),
//             Positioned(
//               right: 8,
//               top: 8,
//               child: Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: const BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Text(
//                   "3",
//                   style: TextStyle(color: Colors.white, fontSize: 10),
//                 ),
//               ),
//             )
//           ],
//         ),

//         // Avatar utilisateur
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: CircleAvatar(
//             backgroundColor: Colors.green,
//             child: const Text("E"), // Initiale
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Accueil"),
      actions: const [
        Icon(Icons.notifications),
        SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}