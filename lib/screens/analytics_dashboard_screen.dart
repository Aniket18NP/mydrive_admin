import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mydrive_admin/screens/driver_details_screen.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  int totalDrivers = 0;
  int totalUsers = 0;
  int totalRides = 0;

  double totalEarnings = 0;

  bool loading = true;

  Map<String, double> monthlyEarnings = {};

  Map<String, int> vehicleTypeCount = {};

  int onlineDrivers = 0;
  int offlineDrivers = 0;

  int activePassengers = 0;
int ongoingTrips = 0;
int completedToday = 0;
int cancelledToday = 0;

  Map<String, int> dailyRides = {};

List<Map<String, dynamic>> topDrivers = [];

  String selectedFilter = "Month";

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    monthlyEarnings.clear();
vehicleTypeCount.clear();
dailyRides.clear();

onlineDrivers = 0;
offlineDrivers = 0;
    final drivers = await firestore.collection("drivers").get();

    for (var driver in drivers.docs) {
      final data = driver.data();

      if (data["isOnline"] == true) {
        onlineDrivers++;
      } else {
        offlineDrivers++;
      }
    }

    topDrivers =
    drivers.docs
        .map((doc) => doc.data())
        .toList();

topDrivers.sort((a, b) {

  final tripsA = a["trips"] ?? 0;
  final tripsB = b["trips"] ?? 0;

  return tripsB.compareTo(tripsA);

});

if (topDrivers.length > 5) {
  topDrivers = topDrivers.sublist(0, 5);
}

    final users = await firestore.collection("users").get();

    activePassengers = users.docs.where((doc) {
  final data = doc.data();
  return data["isActive"] == true;
}).length;

    Query<Map<String, dynamic>> ridesQuery =
    firestore.collection("rides");

DateTime now = DateTime.now();

if (selectedFilter == "Today") {

  DateTime start = DateTime(now.year, now.month, now.day);

  ridesQuery = ridesQuery.where(
    "createdAt",
    isGreaterThanOrEqualTo: Timestamp.fromDate(start),
  );

} else if (selectedFilter == "Week") {

  DateTime start = now.subtract(const Duration(days: 7));

  ridesQuery = ridesQuery.where(
    "createdAt",
    isGreaterThanOrEqualTo: Timestamp.fromDate(start),
  );

} else if (selectedFilter == "Month") {

  DateTime start = DateTime(now.year, now.month, 1);

  ridesQuery = ridesQuery.where(
    "createdAt",
    isGreaterThanOrEqualTo: Timestamp.fromDate(start),
  );

} else if (selectedFilter == "Year") {

  DateTime start = DateTime(now.year, 1, 1);

  ridesQuery = ridesQuery.where(
    "createdAt",
    isGreaterThanOrEqualTo: Timestamp.fromDate(start),
  );

}

final rides = await ridesQuery.get();

    double earnings = 0;

    for (var ride in rides.docs) {

  final data = ride.data() as Map<String, dynamic>;

  final status = data["status"] ?? "";

if (status == "ongoing") {
  ongoingTrips++;
}

if (status == "completed") {
  completedToday++;
}

if (status == "cancelled") {
  cancelledToday++;
}

      earnings += (data["fare"] ?? 0).toDouble();

      // Vehicle Type
      final vehicle = data["rideType"] ?? "Other";

      vehicleTypeCount[vehicle] = (vehicleTypeCount[vehicle] ?? 0) + 1;

      // Daily Rides
      if (data["createdAt"] != null) {
        final date = (data["createdAt"] as Timestamp)
            .toDate()
            .toString()
            .substring(0, 10);

        dailyRides[date] = (dailyRides[date] ?? 0) + 1;
      }

      // Monthly Earnings
      if (data["createdAt"] != null) {
        final month = (data["createdAt"] as Timestamp)
            .toDate()
            .month
            .toString();

        monthlyEarnings[month] =
            (monthlyEarnings[month] ?? 0) + (data["fare"] ?? 0).toDouble();
      }
    }

    setState(() {
      totalDrivers = drivers.docs.length;
      totalUsers = users.docs.length;
      totalRides = rides.docs.length;
      totalEarnings = earnings;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [
                  const Text(
  "Dashboard Filter",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [

      filterChip("Today"),

      const SizedBox(width: 10),

      filterChip("Week"),

      const SizedBox(width: 10),

      filterChip("Month"),

      const SizedBox(width: 10),

      filterChip("Year"),

    ],
  ),
),

const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: dashboardCard(
                          "Drivers",
                          totalDrivers.toString(),
                          Icons.drive_eta,
                          Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: dashboardCard(
                          "Users",
                          totalUsers.toString(),
                          Icons.people,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: dashboardCard(
                          "Rides",
                          totalRides.toString(),
                          Icons.local_taxi,
                          Colors.orange,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: dashboardCard(
                          "Earnings",
                          "Rs ${totalEarnings.toStringAsFixed(2)}",
                          Icons.attach_money,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Monthly Earnings",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,

                        borderData: FlBorderData(show: false),

                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),

                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text("Jan");
                                  case 1:
                                    return const Text("Feb");
                                  case 2:
                                    return const Text("Mar");
                                  case 3:
                                    return const Text("Apr");
                                  case 4:
                                    return const Text("May");
                                  case 5:
                                    return const Text("Jun");
                                  case 6:
                                    return const Text("Jul");
                                  case 7:
                                    return const Text("Aug");
                                  case 8:
                                    return const Text("Sep");
                                  case 9:
                                    return const Text("Oct");
                                  case 10:
                                    return const Text("Nov");
                                  case 11:
                                    return const Text("Dec");
                                  default:
                                    return const Text("");
                                }
                              },
                            ),
                          ),
                        ),

                        barGroups: createBarData(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

const Text(
  "Vehicle Type Distribution",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 20),

SizedBox(
  height: 300,
  child: PieChart(
    PieChartData(
      sections: createVehiclePieChart(),
      sectionsSpace: 2,
      centerSpaceRadius: 50,
    ),
  ),
),

const SizedBox(height: 30),

const Text(
  "Driver Status",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 20),

SizedBox(
  height: 300,
  child: PieChart(
    PieChartData(
      sections: createDriverStatusPieChart(),
      sectionsSpace: 2,
      centerSpaceRadius: 50,
    ),
  ),
),

const SizedBox(height: 30),

const Text(
  "Daily Ride Statistics",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 20),

SizedBox(
  height: 300,
  child: LineChart(
    LineChartData(
      borderData: FlBorderData(show: false),

      titlesData: FlTitlesData(
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),

      lineBarsData: [
        LineChartBarData(
          spots: createDailyRideSpots(),
          isCurved: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: true),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 25),

const Text(
  "📡 Live Activity",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

GridView.count(
  crossAxisCount: 2,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
 childAspectRatio: 1.3,
  children: [
    activityCard(
      "🟢 Online Drivers",
      onlineDrivers.toString(),
      Colors.green,
    ),
    activityCard(
      "👥 Active Passengers",
      activePassengers.toString(),
      Colors.blue,
    ),
    activityCard(
      "🚖 Ongoing Trips",
      ongoingTrips.toString(),
      Colors.orange,
    ),
    activityCard(
      "✅ Completed Today",
      completedToday.toString(),
      Colors.teal,
    ),
    activityCard(
      "❌ Cancelled Today",
      cancelledToday.toString(),
      Colors.red,
    ),
  ],
),

const SizedBox(height: 30),

const Text(
  "🏆 Top Drivers",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: topDrivers.length,
  itemBuilder: (context, index) {

    final driver = topDrivers[index];

    return topDriverCard(driver, index);

  },
),
                  
                ],
              ),
            ),
    );
  }

  Widget dashboardCard(String title, String value, IconData icon, Color color) {
    
    
    return Card(
      elevation: 5,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            Icon(icon, size: 42, color: color),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
    
  }

  List<BarChartGroupData> createBarData() {

  List<BarChartGroupData> bars = [];

  for (int i = 1; i <= 12; i++) {

    double value =
        monthlyEarnings[i.toString()] ?? 0;

    bars.add(
      BarChartGroupData(
        x: i - 1,

        barRods: [

          BarChartRodData(
            toY: value,
            width: 18,
            borderRadius:
                BorderRadius.circular(4),
          ),

        ],
      ),
    );
  }

  return bars;
}
List<PieChartSectionData> createVehiclePieChart() {

  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

  int index = 0;

  return vehicleTypeCount.entries.map((entry) {

    final section = PieChartSectionData(
      color: colors[index % colors.length],
      value: entry.value.toDouble(),
      title: "${entry.key}\n${entry.value}",
      radius: 80,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );

    index++;

    return section;

  }).toList();
}
List<PieChartSectionData> createDriverStatusPieChart() {

  return [

    PieChartSectionData(
      color: Colors.green,
      value: onlineDrivers.toDouble(),
      title: "Online\n$onlineDrivers",
      radius: 80,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),

    PieChartSectionData(
      color: Colors.red,
      value: offlineDrivers.toDouble(),
      title: "Offline\n$offlineDrivers",
      radius: 80,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),

  ];
}
List<FlSpot> createDailyRideSpots() {

  List<FlSpot> spots = [];

  int index = 0;

  dailyRides.forEach((date, rides) {

    spots.add(
      FlSpot(
        index.toDouble(),
        rides.toDouble(),
      ),
    );

    index++;

  });

  return spots;
}

Widget filterChip(String title) {

  final selected = selectedFilter == title;

  return ChoiceChip(

    label: Text(title),

    selected: selected,

    onSelected: (value) {

      setState(() {

        selectedFilter = title;

        loadDashboard();

      });

    },

  );
}
Widget topDriverCard(
    Map<String, dynamic> driver,
    int index,
) {

  String medal = "";

  if (index == 0) {
    medal = "🥇";
  } else if (index == 1) {
    medal = "🥈";
  } else if (index == 2) {
    medal = "🥉";
  } else {
    medal = "🏅";
  }

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 4,

    child: ListTile(

      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.blue,

        child: Text(
          medal,
          style: const TextStyle(fontSize: 22),
        ),
      ),

      title: Text(
        driver["name"] ?? "Unknown Driver",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "⭐ Rating: ${(driver["rating"] ?? 0).toString()}",
          ),

          Text(
            "🚖 Trips: ${(driver["trips"] ?? 0).toString()}",
          ),

          Text(
            "💰 Earnings: Rs ${(driver["earnings"] ?? 0).toString()}",
          ),

        ],
      ),

      trailing: Icon(
        driver["isOnline"] == true
            ? Icons.circle
            : Icons.circle_outlined,
        color: driver["isOnline"] == true
            ? Colors.green
            : Colors.red,
      ),

     onTap: () {

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DriverDetailsScreen(
        driverId: driver["uid"],
      ),
    ),
  );

},

    ),
  );
}
Widget activityCard(
  String title,
  String value,
  Color color,
) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
}
