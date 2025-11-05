
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aashniandco/constants/api_constants.dart';
import 'package:aashniandco/features/designer/model/designer_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart'; // Import for IOClient
part 'designers_event.dart';
part 'designers_state.dart';






// class DesignersBloc extends Bloc<DesignersEvent, DesignersState> {
//   DesignersBloc() : super(DesignersLoading()) {
//     on<FetchDesigners>(_onFetchDesigners);
//   }
//
//   Future<void> _onFetchDesigners(
//       FetchDesigners event, Emitter<DesignersState> emit) async {
//
//     emit(DesignersLoading());
//
//     // This is the Magento API endpoint, not a direct Solr URL. This is correct.
//     final String magentoApiUrl = "https://stage.aashniandco.com/rest/V1/solr/designers";
//     final uri = Uri.parse(magentoApiUrl);
//
//     try {
//       final httpClient = HttpClient()
//         ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//       final ioClient = IOClient(httpClient);
//
//       final response = await ioClient.get(uri);
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//
//         // =========================================================================
//         // ✅ THE DEFINITIVE FIX IS HERE
//         // This code correctly handles the `[ [ "Name A", "Name B", ... ] ]` structure.
//         // =========================================================================
//
//         // 1. Check if the decoded response is a List and is not empty.
//         if (jsonResponse is List && jsonResponse.isNotEmpty) {
//
//           // 2. Get the INNER list. This is the list that actually contains the designer names.
//           final dynamic innerList = jsonResponse[0];
//
//           // 3. Verify that the inner element is also a List.
//           if (innerList is List) {
//
//             // 4. Now that we have the final list of names, map it to your Designer model.
//             final List<Designer> designers = innerList
//                 .map((name) => Designer(name: name.toString()))
//                 .toList();
//
//             // 5. Emit the successful state with the parsed data.
//             emit(DesignersLoaded(designers));
//
//           } else {
//             // This error will happen if the response is like `[ "some string" ]` instead of `[ [ ... ] ]`
//             emit(DesignersError("Failed to parse: The inner element of the response is not a list."));
//           }
//         } else {
//           // This will handle cases where the API returns an empty list `[]` or something unexpected.
//           emit(DesignersError("Failed to parse: The API response is not a valid or non-empty list."));
//         }
//       } else {
//         emit(DesignersError("Failed to load designers. Status: ${response.statusCode}, Body: ${response.body}"));
//       }
//     } catch (e) {
//       emit(DesignersError("An error occurred while fetching designers: $e"));
//     }
//   }
// }

//28/7/2025

class DesignersBloc extends Bloc<DesignersEvent, DesignersState> {
  DesignersBloc() : super(DesignersLoading()) {
    on<FetchDesigners>(_onFetchDesigners);



  }
  // final String solrUrl = "https://78b1-114-143-109-126.ngrok-free.app/solr/aashni_dev/select?"
  //     "q=*:*&fq=categories-store-1_url_path:%22designers%22"
  //     "&facet=true&facet.field=designer_name&facet.limit=-1";

  Future<void> _onFetchDesigners(
      FetchDesigners event, Emitter<DesignersState> emit) async {
    emit(DesignersLoading());

    final url = Uri.parse("https://aashniandco.com/rest/V1/solr/designers");

    try {
      // ✅ Create a custom HttpClient that ignores SSL certificate validation
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.get(url, headers: {
        "Connection": "keep-alive",
        "Content-Type": "application/json",
      });
print ("Desinger URL>>$url");
      print("Raw API Response:designer bt>> ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // 👉 facet_fields lives at index 2
        final facetFields =
        jsonResponse[2]['facet_fields']['designer_name'] as List<dynamic>;

        List<Designer> designers = [];

        // ✅ pick only the names at even indexes
        for (int i = 0; i < facetFields.length; i += 2) {
          designers.add(Designer(name: facetFields[i] as String));
        }

        emit(DesignersLoaded(designers));
      } else {
        emit(DesignersError("Failed to load designers: ${response.statusCode}"));
      }



    } catch (e) {
      emit(DesignersError("Error fetching designers: $e"));
    }
  }

//
  // Future<void> _onFetchDesigners(
  //     FetchDesigners event, Emitter<DesignersState> emit) async {
  //   emit(DesignersLoading());
  //   // http://130.61.35.64:8983/solr/aashni_dev/select?q=*:*&fq=categories-store-1_url_path:%22designers%22&facet=true&facet.field=designer_name&facet.limit=-1
  //   final url = Uri.parse(
  //       "http://130.61.35.64:8983/solr/aashni_dev/select?q=*:*&fq=categories-store-1_url_path:%22designers%22&facet=true&facet.field=designer_name&facet.limit=-1");
  //
  //   try {
  //     // ✅ Create a custom HttpClient that ignores SSL certificate validation
  //     HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  //
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     final response = await ioClient.get(url, headers: {
  //       "Connection": "keep-alive",
  //     });
  //
  //     // ✅ Print the raw response for debugging
  //     print("Raw API Response: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       print("Parsed JSON Response: $jsonResponse");
  //       final List<dynamic> facetFields =
  //       jsonResponse['facet_counts']['facet_fields']['designer_name'];
  //
  //       List<Designer> designers = facetFields
  //           .where((e) => e is String)
  //           .map((name) => Designer.fromJson(name))
  //           .toList();
  //
  //       emit(DesignersLoaded(designers));
  //     } else {
  //       emit(DesignersError("Failed to load designers: ${response.statusCode}"));
  //     }
  //   } catch (e) {
  //     emit(DesignersError("Error fetching designers: $e"));
  //   }
  // }
}



// import 'dart:async';
// import 'dart:convert';
// import 'package:aashniandco/features/designer/model/new_in_model.dart';
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:http/http.dart' as http;
//
//
// part 'new_in_theme_event.dart';
// part 'new_in_theme_state.dart';
//
// class DesignersBloc extends Bloc<DesignersEvent, DesignersState> {
//   DesignersBloc() : super(DesignersLoading()) {
//     on<FetchDesigners>(_onFetchDesigners);
//   }
//

// prod solr
//   Future<void> _onFetchDesigners(
//       FetchDesigners event, Emitter<DesignersState> emit) async {
//     emit(DesignersLoading());
//
//     final url = Uri.parse(
//         "http://130.61.35.64:8983/solr/aashni_dev/select?q=*:*&fq=categories-store-1_url_path:%22designers%22&facet=true&facet.field=designer_name&facet.limit=-1");
//
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         final List<dynamic> facetFields =
//         jsonResponse['facet_counts']['facet_fields']['designer_name'];
//
//         List<Designer> designers = facetFields
//             .where((e) => e is String)
//             .map((name) => Designer.fromJson(name))
//             .toList();
//
//         emit(DesignersLoaded(designers));
//       } else {
//         emit(DesignersError("Failed to load designers"));
//       }
//     } catch (e) {
//       emit(DesignersError("Error fetching designers: $e"));
//     }
//   }

//"https://stage.aashniandco.com/rest/V1/solr/products"

Future<void> _onFetchDesigners(
    FetchDesigners event, Emitter<DesignersState> emit) async {
  emit(DesignersLoading());

  final url = Uri.parse(
      ApiConstants.designers);

  try {
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(httpClient);

    final response = await ioClient.get(
        url, headers: {"Connection": "keep-alive"});

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);

      print("Parsed JSON Response: $jsonResponse");


      if (jsonResponse.isNotEmpty &&
          jsonResponse.last is Map<String, dynamic>) {
        final Map<String, dynamic> facetCounts = jsonResponse.last;

        if (facetCounts.containsKey('facet_fields') &&
            facetCounts['facet_fields'].containsKey('designer_name')) {
          final List<
              dynamic> facetFields = facetCounts['facet_fields']['designer_name'];

          // ✅ Extract only string values (designer names) from facetFields
          List<Designer> designers = [];
          for (int i = 0; i < facetFields.length; i += 2) {
            if (facetFields[i] is String) {
              designers.add(Designer(name: facetFields[i]));
            }
          }

          emit(DesignersLoaded(designers));
        } else {
          emit(DesignersError("Invalid API Response: Missing 'facet_fields'"));
        }
      } else {
        emit(DesignersError("Invalid API Response: Expected a JSON object"));
      }
    } else {
      emit(DesignersError("Failed to load designers: ${response.statusCode}"));
    }
  } catch (e) {
    emit(DesignersError("Error fetching designers: $e"));
  }
}
