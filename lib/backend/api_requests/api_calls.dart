import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start OpenAI ChatGPT Group Code

class OpenAIChatGPTGroup {
  static String getBaseUrl() => 'https://api.openai.com/v1';
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  static SendFullPromptCall sendFullPromptCall = SendFullPromptCall();
}

class SendFullPromptCall {
  Future<ApiCallResponse> call({
    dynamic promptJson,
    String? apiKey = '',
  }) async {
    final baseUrl = OpenAIChatGPTGroup.getBaseUrl();

    final prompt = _serializeJson(promptJson);
    final ffApiRequestBody = '''
{
   "model":"gpt-3.5-turbo",
   "messages":[
      {
         "role":"system",
         "content":"Welcome to MediTracker! How can we assist you today?"
      },
      {
         "role":"user",
         "content":"Thank you for the information!"
      },
      {
         "role":"system",
         "content":"You're welcome! I'm here to help."
      },
   
      {
         "role":"user",
         "content":"What is Panadol used for?"
      },
      {
         "role":"system",
         "content":"Panadol is used for the relief of headaches, pain, toothache, and fever."
      },
      {
         "role":"user",
         "content":"Can I take Panadol if I have a cold?"
      },
      {
         "role":"system",
         "content":"Yes, Panadol can help relieve symptoms such as headache and fever associated with a cold."
      },
      {
         "role":"user",
         "content":"Is Panadol safe for children?"
      },
      {
         "role":"system",
         "content":"Panadol is generally safe for children, but it's important to use the appropriate dosage based on the child's age and weight. Consult a healthcare professional for proper guidance."
      },
      {
         "role":"user",
         "content":"What are the common side effects of Panadol?"
      },
      {
         "role":"system",
         "content":"Common side effects of Panadol may include nausea, stomach upset, or allergic reactions. However, not everyone experiences these side effects."
      },
      {
         "role":"user",
         "content":"Can I take Panadol if I'm pregnant?"
      },
      {
         "role":"system",
         "content":"It's generally considered safe to take Panadol during pregnancy, but it's always best to consult with your healthcare provider before taking any medication while pregnant."
      },
      {
         "role":"user",
         "content":"What is the recommended dosage for Panadol?"
      },
      {
         "role":"system",
         "content":"The recommended dosage of Panadol depends on various factors such as age, weight, and the specific formulation. Always follow the instructions provided on the packaging or consult a healthcare professional for appropriate dosing guidance."
      },
      {
         "role":"user",
         "content":"Is Panadol available without a prescription?"
      },
      {
         "role":"system",
         "content":"Yes, Panadol is available over-the-counter, and you can purchase it without a prescription. However, it's important to follow the recommended dosage and usage guidelines."
      },
      {
         "role":"user",
         "content":"What is the shelf life of Panadol?"
      },
      {
         "role":"system",
         "content":"The shelf life of Panadol varies depending on the specific formulation and packaging. Generally, it is around 2 to 3 years. It's important to check the expiration date on the packaging and discard any expired medication."
      },
      {
         "role":"user",
         "content":"Can I take Panadol with other medications?"
      },
      {
         "role":"system",
         "content":"It's essential to consult a healthcare professional or pharmacist before taking Panadol with other medications to ensure there are no potential interactions or contraindications. Some medications may interact with Panadol and affect its effectiveness or increase the risk of side effects."
      },
      {
         "role":"user",
         "content":"Is Panadol suitable for individuals with liver problems?"
      },
      {
         "role":"system",
         "content":"Individuals with liver problems should consult their healthcare provider before taking Panadol. Excessive or long-term use of Panadol can potentially cause liver damage, especially when exceeding the recommended dosage."
      },
      {
         "role":"user",
         "content":"What is ibuprofen used for?"
      },
      {
         "role":"system",
         "content":"Ibuprofen is a nonsteroidal anti-inflammatory drug (NSAID) used to relieve pain, reduce inflammation, and lower fever. It can be used to treat conditions such as headaches, muscle aches, menstrual cramps, and arthritis."
      },
      {
         "role":"user",
         "content":"Is ibuprofen safe for children?"
      },
      {
         "role":"system",
         "content":"Ibuprofen is generally safe for children, but it's important to use the appropriate dosage based on the child's age and weight. Consult a healthcare professional for proper guidance."
      },
      {
         "role":"user",
         "content":"Can I take ibuprofen if I have a stomach ulcer?"
      },
      {
         "role":"system",
         "content":"Individuals with a stomach ulcer or a history of gastrointestinal bleeding should avoid taking ibuprofen without consulting their healthcare provider. Ibuprofen can potentially worsen stomach ulcers and increase the risk of bleeding."
      },
      {
         "role":"user",
         "content":"What are the common side effects of ibuprofen?"
      },
      {
         "role":"system",
         "content":"Common side effects of ibuprofen may include stomach upset, heartburn, nausea, drowsiness, or allergic reactions. However, not everyone experiences these side effects."
      },
      {
         "role":"user",
         "content":"Can I take ibuprofen if I'm pregnant?"
      },
      {
         "role":"system",
         "content":"It's generally recommended to avoid ibuprofen during pregnancy, particularly in the later stages, as it may pose risks to the developing fetus. Consult your healthcare provider for appropriate pain relief options during pregnancy."
      },
      {
         "role":"user",
         "content":"What is the recommended dosage for ibuprofen?"
      },
      {
         "role":"system",
         "content":"The recommended dosage of ibuprofen depends on various factors such as age, weight, and the specific formulation. Always follow the instructions provided on the packaging or consult a healthcare professional for appropriate dosing guidance."
      },
      {
         "role":"user",
         "content":"Is ibuprofen available without a prescription?"
      },
      {
         "role":"system",
         "content":"Yes, ibuprofen is available over-the-counter, and you can purchase it without a prescription. However, it's important to follow the recommended dosage and usage guidelines."
      },
      {
         "role":"user",
         "content":"What is the shelf life of ibuprofen?"
      },
      {
         "role":"system",
         "content":"The shelf life of ibuprofen varies depending on the specific formulation and packaging. Generally, it is around 2 to 3 years. It's important to check the expiration date on the packaging and discard any expired medication."
      },
      {
         "role":"user",
         "content":"Can I take ibuprofen if I'm allergic to aspirin?"
      },
      {
         "role":"system",
         "content":"Some individuals who are allergic to aspirin may also be allergic to ibuprofen or other NSAIDs. It's recommended to consult with a healthcare professional or pharmacist to determine if ibuprofen is safe for you."
      },
      {
         "role":"user",
         "content":"Is ibuprofen suitable for individuals with kidney problems?"
      },
      {
         "role":"system",
         "content":"Individuals with kidney problems should consult their healthcare provider before taking ibuprofen. Prolonged or excessive use of ibuprofen can potentially cause kidney damage, especially when exceeding the recommended dosage."
      },
      {
         "role":"user",
         "content":"What is the difference between paracetamol and ibuprofen?"
      },
      {
         "role":"system",
         "content":"Paracetamol (also known as acetaminophen) and ibuprofen are both pain relievers, but they belong to different drug classes. Paracetamol mainly works by reducing pain and fever, while ibuprofen also has anti-inflammatory properties, making it more effective for conditions involving inflammation, such as arthritis."
      },
      {
         "role":"user",
         "content":"Can I take paracetamol and ibuprofen together?"
      },
      {
         "role":"system",
         "content":"In some cases, it may be safe to take paracetamol and ibuprofen together for enhanced pain relief. However, it's important to consult with a healthcare professional or pharmacist to ensure appropriate dosing and to check for any potential interactions or contraindications."
      },
      {
         "role":"user",
         "content":"What is codeine used for?"
      },
      {
         "role":"system",
         "content":"Codeine is an opioid medication used for the relief of moderate to severe pain. It can also be used as a cough suppressant in some formulations."
      },
      {
         "role":"user",
         "content":"Is codeine available over-the-counter?"
      },
      {
         "role":"system",
         "content":"No, codeine is a prescription-only medication in many countries due to its potential for misuse, dependence, and side effects. It should be used under the guidance of a healthcare professional."
      },
      {
         "role":"user",
         "content":"What are the common side effects of codeine?"
      },
      {
         "role":"system",
         "content":"Common side effects of codeine may include drowsiness, constipation, nausea, vomiting, and respiratory depression. It's important to use codeine as prescribed and report any concerning side effects to your healthcare provider."
      },
      {
         "role":"user",
         "content":"Can I take codeine if I'm breastfeeding?"
      },
      {
         "role":"system",
         "content":"Codeine can pass into breast milk and may cause harm to a nursing infant. It's generally recommended to avoid codeine while breastfeeding. Consult your healthcare provider for alternative pain relief options that are safe during breastfeeding."
      },
      {
         "role":"user",
         "content":"What is the recommended dosage for codeine?"
      },
      {
         "role":"system",
         "content":"The recommended dosage of codeine varies depending on the formulation, strength, and individual factors. It should always be used as directed by a healthcare professional. Follow the prescribed dosage instructions and do not exceed the recommended limits."
      },
      {
         "role":"user",
         "content":"Can I drink alcohol while taking codeine?"
      },
      {
         "role":"system",
         "content":"Drinking alcohol while taking codeine can increase the risk of drowsiness, dizziness, and other central nervous system depressant effects. It's generally recommended to avoid alcohol when using codeine."
      },
      {
         "role":"user",
         "content":"What is the shelf life of codeine?"
      },
      {
         "role":"system",
         "content":"The shelf life of codeine varies depending on the specific formulation and packaging. Generally, it is around 2 to 3 years. It's important to check the expiration date on the packaging and discard any expired medication."
      },
      {
         "role":"user",
         "content":"Is codeine addictive?"
      },
      {
         "role":"system",
         "content":"Codeine is an opioid medication, and prolonged or misuse of codeine can lead to dependence and addiction. It should be used only as prescribed by a healthcare professional and for the recommended duration."
      },
      {
         "role":"user",
         "content":"What is the difference between generic and brand-name medications?"
      },
      {
         "role":"system",
         "content":"Generic medications contain the same active ingredients as their brand-name counterparts but are often sold at a lower price. The main difference lies in the branding, packaging, and sometimes the inactive ingredients. Both generic and brand-name medications undergo rigorous testing for safety and effectiveness."
      },
      {
         "role":"user",
         "content":"Can I substitute a generic medication for a brand-name one?"
      },
      {
         "role":"system",
         "content":"In many cases, generic medications can be substituted for brand-name ones, as they contain the same active ingredients. However, it's important to consult with a healthcare professional or pharmacist to ensure the substitution is appropriate and to address any specific concerns you may have."
      },
      {
         "role":"user",
         "content":"What should I do if I miss a dose of my medication?"
      },
      {
         "role":"system",
         "content":"If you miss a dose of your medication, it's generally recommended to take it as soon as you remember. However, if it's close to the time for your next dose, skip the missed dose and resume your regular dosing schedule. Do not double the dose to make up for the missed one. If you have any doubts or concerns, consult your healthcare provider or pharmacist."
      },
      {
         "role":"user",
         "content":"Can I crush or split my medication?"
      },
      {
         "role":"system",
         "content":"Crushing or splitting medication should only be done under the guidance of a healthcare professional or pharmacist. Some medications have specific formulations that should not be crushed or split, as it may affect their effectiveness or cause unintended side effects. Always follow the instructions provided or consult a healthcare professional for appropriate administration."
      },
      {
         "role":"user",
         "content":"What should I do if I experience an allergic reaction to a medication?"
      },
      {
         "role":"system",
         "content":"If you experience signs of an allergic reaction, such as hives, swelling, difficulty breathing, or severe rash, it's important to seek immediate medical attention. Stop taking the medication and inform your healthcare provider about the symptoms you are experiencing."
      },
      {
         "role":"user",
         "content":"How should I store my medication?"
      },
      {
         "role":"system",
         "content":"The proper storage of medication depends on the specific medication and its instructions. In general, it's important to store medications in a cool, dry place away from direct sunlight, moisture, and heat. Some medications may require refrigeration. Always check the packaging or consult a healthcare professional or pharmacist for specific storage instructions."
      },
      {
         "role":"user",
         "content":"Can I take herbal supplements with my prescribed medications?"
      },
      {
         "role":"system",
         "content":"Herbal supplements can interact with prescribed medications and affect their effectiveness or increase the risk of side effects. It's important to inform your healthcare provider about any herbal supplements you are taking to ensure there are no potential interactions. Your healthcare provider can provide guidance on the safe use of herbal supplements alongside your prescribed medications."
      },
      {
         "role":"user",
         "content":"What is the recommended duration for taking antibiotics?"
      },
      {
         "role":"system",
         "content":"The recommended duration for taking antibiotics varies depending on the specific infection and the prescribed medication. It's important to complete the full course of antibiotics as prescribed by your healthcare provider, even if you start feeling better before the course is completed. This helps ensure the infection is fully treated and reduces the risk of antibiotic resistance."
      },
      {
         "role":"user",
         "content":"Can I take my medication with food?"
      },
      {
         "role":"system",
         "content":"Some medications can be taken with or without food, while others may need to be taken on an empty stomach. It's important to follow the specific instructions provided with your medication or consult a healthcare professional or pharmacist for proper administration guidelines."
      },
      {
         "role":"user",
         "content":"What should I do if I accidentally take more than the prescribed dose of my medication?"
      },
      {
         "role":"system",
         "content":"If you accidentally take more than the prescribed dose of your medication, it's important to seek immediate medical attention. Contact your healthcare provider or local poison control center for guidance on how to manage the situation. Provide them with detailed information about the medication, the dosage you took, and the time of ingestion."
      },
      {
         "role":"user",
         "content":"Can I drive or operate machinery while taking my medication?"
      },
      {
         "role":"system",
         "content":"Some medications can cause drowsiness, dizziness, or other side effects that can impair your ability to drive or operate machinery safely. It's important to read the medication's instructions and warnings and consult with your healthcare provider or pharmacist if you have any concerns. They can provide guidance on whether it's safe to engage in such activities while taking your medication."
      },
      {
         "role":"user",
         "content":"Can I refill my prescription online?"
      },
      {
         "role":"system",
         "content":"Many pharmacies offer online prescription refill services. You can check with your pharmacy if they have an online platform or mobile app for prescription refills. However, certain prescriptions may require a physical visit to the pharmacy or consultation with a healthcare provider. It's best to contact your pharmacy directly for specific information and guidance on refilling your prescription online."
      },
      {
         "role":"user",
         "content":"Can I stop taking my medication if I feel better?"
      },
      {
         "role":"system",
         "content":"It's important to follow the prescribed duration of your medication, even if you start feeling better before the course is completed. Stopping medication prematurely can lead to incomplete treatment and a potential relapse of the condition. If you have any concerns about your medication, it's best to consult with your healthcare provider before making any changes to your treatment plan."
      },
      {
         "role":"user",
         "content":"What should I do if I accidentally swallow a non-prescription medication meant for external use only?"
      },
      {
         "role":"system",
         "content":"If you accidentally swallow a medication meant for external use only, it's important to seek immediate medical attention. Contact your healthcare provider or local poison control center for guidance. Provide them with detailed information about the medication, the quantity ingested, and the time of ingestion."
      },
      {
         "role":"user",
         "content":"What should I do if I have trouble swallowing my medication?"
      },
      {
         "role":"system",
         "content":"If you have trouble swallowing your medication, there are a few options you can consider. You can talk to your healthcare provider or pharmacist about alternative formulations, such as a liquid or chewable version if available. Some medications can be crushed or mixed with food or beverages, but it's essential to check with a healthcare professional or pharmacist first to ensure it's safe to do so. They can provide you with guidance on how to take your medication comfortably and effectively."
      },
      {
         "role":"user",
         "content":"Can I take my medication past its expiration date?"
      },
      {
         "role":"system",
         "content":"It's generally not recommended to take medication past its expiration date. Medications can lose effectiveness or degrade over time, and using expired medication may not provide the desired therapeutic effect. It's best to check the expiration date on the packaging and discard any expired medications. If you have any concerns or questions, consult with your healthcare provider or pharmacist for appropriate guidance."
      },
      {
         "role":"user",
         "content":"What should I do if I vomit after taking my medication?"
      },
      {
         "role":"system",
         "content":"If you vomit shortly after taking your medication, it's possible that the medication may not have been fully absorbed. In such cases, it's generally recommended to wait for a while and take another dose if instructed to do so by your healthcare provider. However, if you continue to experience vomiting or have concerns, it's best to consult with your healthcare provider or pharmacist for guidance specific to your situation."
      },
      {
         "role":"user",
         "content":"Can I take my medication with other supplements?"
      },
      {
         "role":"system",
         "content":"Some supplements can interact with medications and affect their effectiveness or increase the risk of side effects. It's important to inform your healthcare provider about any supplements you are taking, including vitamins, minerals, and herbal products. They can provide guidance on any potential interactions and help you make informed decisions about taking your medication alongside other supplements."
      },
      {
         "role":"user",
         "content":"Can I take my medication on an empty stomach?"
      },
      {
         "role":"system",
         "content":"Some medications need to be taken on an empty stomach for optimal absorption, while others should be taken with food to minimize stomach upset. It's important to follow the specific instructions provided with your medication or consult a healthcare professional or pharmacist for proper administration guidelines."
      },
      {
         "role":"user",
         "content":"What should I do if I accidentally drop my medication on the floor?"
      },
      {
         "role":"system",
         "content":"If you accidentally drop your medication on the floor, it's generally recommended to discard that dose and take a new one. Contact your healthcare provider or pharmacist if you're concerned about a potential waste of medication or if it affects the availability of your prescription. They can provide further guidance specific to your situation."
      }
   ]
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Send Full Prompt',
      apiUrl: '${baseUrl}/chat/completions',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${apiKey}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End OpenAI ChatGPT Group Code

/// Start FinanceData Group Code

class FinanceDataGroup {
  static String getBaseUrl({
    String? userId = '',
  }) =>
      'https://finance.meditrackerglobal.com/';
  static Map<String, String> headers = {};
  static TopSellerCall topSellerCall = TopSellerCall();
  static IncomeCall incomeCall = IncomeCall();
  static WorstSellerCall worstSellerCall = WorstSellerCall();
}

class TopSellerCall {
  Future<ApiCallResponse> call({
    String? userId = '',
  }) async {
    final baseUrl = FinanceDataGroup.getBaseUrl(
      userId: userId,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Top Seller',
      apiUrl: '${baseUrl}TopSeller/',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'UserId': userId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class IncomeCall {
  Future<ApiCallResponse> call({
    String? userId = '',
  }) async {
    final baseUrl = FinanceDataGroup.getBaseUrl(
      userId: userId,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Income',
      apiUrl: '${baseUrl}/Income/',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'UserId': userId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class WorstSellerCall {
  Future<ApiCallResponse> call({
    String? userId = '',
  }) async {
    final baseUrl = FinanceDataGroup.getBaseUrl(
      userId: userId,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Worst Seller',
      apiUrl: '${baseUrl}/WorstSeller/',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'UserId': userId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End FinanceData Group Code

/// Start AirTable Finance Records Group Code

class AirTableFinanceRecordsGroup {
  static String getBaseUrl() => 'https://api.airtable.com/v0/';
  static Map<String, String> headers = {
    'Authorization':
        'Bearer ' + 'patuai' + 'GTiJPSpKgV2' + '.abc62a6af77f9845653498d2d1c8c3bfdb4ba5b212e76d7581312f33fb597eb7',
    'Content-Type': 'application/json',
  };
  static AddIncomeCall addIncomeCall = AddIncomeCall();
  static AddExpensesCall addExpensesCall = AddExpensesCall();
  static SumIncomeCall sumIncomeCall = SumIncomeCall();
}

class AddIncomeCall {
  Future<ApiCallResponse> call({
    String? ownerId = '',
    double? amount,
    String? date = '',
  }) async {
    final baseUrl = AirTableFinanceRecordsGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "records": [
    {
      "fields": {
        "OwnerId": "${ownerId}",
        "Amount": ${amount},
        "Date": "${date}"
      }
    }
  ]
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Add Income',
      apiUrl: '${baseUrl}/appjCoTN8WRmXIlDe/Income',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer ' + 'patuai' + 'GTiJPSpKgV2' + '.abc62a6af77f9845653498d2d1c8c3bfdb4ba5b212e76d7581312f33fb597eb7',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AddExpensesCall {
  Future<ApiCallResponse> call({
    String? ownerId = '',
    double? amount,
    String? date = '',
  }) async {
    final baseUrl = AirTableFinanceRecordsGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "records": [
    {
      "fields": {
        "OwnerId": "${ownerId}",
        "Amount": ${amount},
        "Date": "${date}"
      }
    }
  ]
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Add Expenses',
      apiUrl: '${baseUrl}/appjCoTN8WRmXIlDe/Expenses',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer ' + 'patuai' + 'GTiJPSpKgV2' + '.abc62a6af77f9845653498d2d1c8c3bfdb4ba5b212e76d7581312f33fb597eb7',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SumIncomeCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = AirTableFinanceRecordsGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'SumIncome',
      apiUrl: '${baseUrl}appjCoTN8WRmXIlDe/Income',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer ' + 'patuai' + 'GTiJPSpKgV2' + '.abc62a6af77f9845653498d2d1c8c3bfdb4ba5b212e76d7581312f33fb597eb7',
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End AirTable Finance Records Group Code

/// Start DPO API Group Code

class DpoApiGroup {
  static String getBaseUrl() => 'https://secure.3gdirectpay.com/API/v6/';
  static Map<String, String> headers = {};
}

/// End DPO API Group Code

/// Start DPO PAYMENT URL Group Code

class DpoPaymentUrlGroup {
  static String getBaseUrl({
    String? companyToken = 'C71C6A2C-DB15-42B9-9867-D74CA19EED60',
  }) =>
      'https://secure.3gdirectpay.com/API/v6/';
  static Map<String, String> headers = {
    'Content-Type': 'application/xml',
    'Accept': 'application/xml',
  };
  static CreateTokenCall createTokenCall = CreateTokenCall();
}

class CreateTokenCall {
  Future<ApiCallResponse> call({
    double? amount,
    String? name = '',
    String? email = '',
    String? mobileNumber = '',
    String? address = '',
    String? date = '',
    String? companyToken = 'C71C6A2C-DB15-42B9-9867-D74CA19EED60',
  }) async {
    final baseUrl = DpoPaymentUrlGroup.getBaseUrl(
      companyToken: companyToken,
    );

    final ffApiRequestBody = '''
<API3G>
  <CompanyToken>"${companyToken}"</CompanyToken>
  <Request>createToken</Request>
  <CustomerEmail>"${email}"</CustomerEmail>
  <CustomerFirstName>"${name}"</CustomerFirstName>
  <CustomerAddress>"${address}"</CustomerAddress>
  <CustomerCity>Lusaka</CustomerCity>
  <CustomerCountry>ZM</CustomerCountry>
  <CustomerDialCode>ZM</CustomerDialCode>
  <CustomerPhone>"${mobileNumber}"</CustomerPhone>
  <Transaction>
    <PaymentAmount>${amount}</PaymentAmount>
    <PaymentCurrency>zmk</PaymentCurrency>
    <CompanyRef>49FKEOA</CompanyRef>
    <RedirectURL>http://www.domain.com/payurl.php</RedirectURL>
    <BackURL>http://www.domain.com/backurl.php </BackURL>
    <CompanyRefUnique>0</CompanyRefUnique>
    <PTL>5</PTL>
  </Transaction>
  <Services>
    <Service>
      <ServiceType>88612</ServiceType>
      <ServiceDescription>Online Ticketing Solution</ServiceDescription>
      <ServiceDate>${date}</ServiceDate>
    </Service>
  </Services>
</API3G>''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Token',
      apiUrl: '${baseUrl}/CreateToken',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/xml',
        'Accept': 'application/xml',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.TEXT,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End DPO PAYMENT URL Group Code

class MobileMoneyCall {
  static Future<ApiCallResponse> call({
    String? transactionreference = '',
  }) async {
    final ffApiRequestBody = '''
{
"amount": 10.50,
        "currency": "ZMK",
        "customerEmail": "mundia@getsparco.com",
        "customerFirstName": "Mundia",
        "customerLastName": "Mwala",
        "customerPhone": "0961453688",
        "merchantPublicKey": "4589f65984104e48a303db5d67cb4fde",
        "transactionName": "Order #123 ",
        "transactionReference": "5f5565270b6594500c052io3",
        "wallet": "0961453688",
        "chargeMe": true  
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'MobileMoney',
      apiUrl: 'https://checkout.sparco.io/gateway/api/v1/checkout',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'sk-' + 'rcotteD1OPjv3Zu9q4dCT3' + 'BlbkFJ39hmMVyo1GqT6zrawT3Y',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: true,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic payment(dynamic response) => getJsonField(
        response,
        r'''$.paymentUrl''',
      );
}

class SubscriptionCall {
  static Future<ApiCallResponse> call({
    String? transactionreference = '',
    String? customerFirstName = '',
    String? customerLastName = '',
    String? webhookUrl = '',
    String? customerCity = '',
  }) async {
    final ffApiRequestBody = '''
{
  "transactionName": "Test",
  "amount": 500,
  "currency": "ZMK",
  "transactionReference: ": "${transactionreference}",
  "customerFirstName": "${customerFirstName}",
  "customerLastName": "${customerLastName}",
  "customerEmail": "test@mail.com",
  "customerPhone": "+26961234567",
  "customerAddr": "Test",
  "customerCity": "${customerCity}",
  "customerState": "Lusaka",
  "customerCountryCode": "ZM",
  "customerPostalCode": "12345",
  "merchantPublicKey": "4589f65984104e48a303db5d67cb4fde",
  "webhookUrl": "${webhookUrl}",
  "autoReturn": true
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Subscription',
      apiUrl: 'https://checkout.sparco.io/gateway/api/v1/checkout',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': '4589f65984104e48a303db5d67cb4fde',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: true,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic paymentLink(dynamic response) => getJsonField(
        response,
        r'''$.paymentUrl''',
      );
}

class DataCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'Data',
      apiUrl:
          'https://sheet.best/api/sheets/d8dda492-a8ee-481f-92d6-10ce598cfa91',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CountryCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'Country',
      apiUrl: 'https://sheetlabs.com/STAC/CountryCode',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? code(dynamic response) => (getJsonField(
        response,
        r'''$[:].ISO4217currencycountryname''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class DrugsCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'Drugs',
      apiUrl: 'https://sheetlabs.com/STAC/Drugs',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? productName(dynamic response) => (getJsonField(
        response,
        r'''$[:].ProductName''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class FinancialsCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    int? income,
    int? expenditure,
  }) async {
    final ffApiRequestBody = '''
[
  {
    "Income": ${income},
    "Expenditure": ${expenditure},
    "User": "${email}"
  }
]''';
    return ApiManager.instance.makeApiCall(
      callName: 'Financials',
      apiUrl: 'https://app.sheetlabs.com/STAC/UserData',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: true,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class FinancialsGETCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    int? income,
    int? expenditure,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'FinancialsGET',
      apiUrl: 'https://app.sheetlabs.com/STAC/UserData',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: true,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SendEmailCall {
  static Future<ApiCallResponse> call({
    String? toEmail = '',
    String? subject = '',
    String? content = '',
  }) async {
    final ffApiRequestBody = '''
{
  "personalizations": [
    {
      "to": [
        {
          "email": "${toEmail}"
        }
      ],
      "subject": "${subject}"
    }
  ],
  "content": [
    {
      "type": "text/plain",
      "value": "${content}"
    }
  ],
  "from": {
    "email": "developer@thestackone.com",
    "name": "MediTracker"
  },
  "reply_to": {
    "email": "developer@thestackone.com",
    "name": "MediTrackder"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'sendEmail',
      apiUrl: 'https://api.sendgrid.com/v3/mail/send',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer ' + 'SG.' + '26qW7G0CTtuOXX7TDY9j3Q' + '.IWTrxjbfjEgBaUM4yGWJ1rOIpVFol8TDVjP2rJMNX8I',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class IpCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'ip',
      apiUrl: 'https://api.ipify.org/?format=json',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? ip(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.ip''',
      ));
}

class LocationCurrencyCall {
  static Future<ApiCallResponse> call({
    String? ip = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'LocationCurrency',
      apiUrl: 'https://api.ipgeolocation.io/ipgeo',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'apiKey': "19e6faff3140445a951e513302c06a02",
        'ip': ip,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? countryCode(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.country_code2''',
      ));
}

class APICallCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'APICall',
      apiUrl: 'https://buy.stripe.com/6oEcOwfEu1sG3ja7ss',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetStripeUserCall {
  static Future<ApiCallResponse> call({
    String? email = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetStripeUser',
      apiUrl: 'https://api.stripe.com/v1/customers',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer ' + 'sk_live_' + '51QDNJtGbVS90B1TZqqEBlppExttfUubMy4vCvljfBQ664G7ltvebhNtDlW8pGfRRYTEbrvyEt0OWwbzDIkGIbrVO00YTgy6pXa',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      params: {
        'email': email,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? customerId(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data[0].id''',
      ));
}

class DeleteStripeUserCall {
  static Future<ApiCallResponse> call({
    String? id = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'DeleteStripeUser',
      apiUrl: 'https://api.stripe.com/v1/customers/${id}',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization':
            'Bearer ' + 'sk_live_' + '51QDNJtGbVS90B1TZqqEBlppExttfUubMy4vCvljfBQ664G7ltvebhNtDlW8pGfRRYTEbrvyEt0OWwbzDIkGIbrVO00YTgy6pXa',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? customerId(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data[0].id''',
      ));
}

class SubscriptionstatusCall {
  static Future<ApiCallResponse> call({
    String? customer = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'subscriptionstatus',
      apiUrl: 'https://api.stripe.com/v1/subscriptions',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer ' + 'sk_live_' + '51QDNJtGbVS90B1TZqqEBlppExttfUubMy4vCvljfBQ664G7ltvebhNtDlW8pGfRRYTEbrvyEt0OWwbzDIkGIbrVO00YTgy6pXa',
      },
      params: {
        'customer': customer,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? subscription(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
  static String? status(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].status''',
      ));
  static String? packageName(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data[0].items.data[0].plan.product''',
      ));
  static int? endDate(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[0].current_period_end''',
      ));
  static int? startDate(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[0].current_period_start''',
      ));
  static String? subId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[0].id''',
      ));
}

class UpdatesubscriptionsCall {
  static Future<ApiCallResponse> call({
    String? subscription = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Updatesubscriptions',
      apiUrl: 'https://api.stripe.com/v1/subscriptions/${subscription}',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer ' + 'sk_live_' + '51QDNJtGbVS90B1TZqqEBlppExttfUubMy4vCvljfBQ664G7ltvebhNtDlW8pGfRRYTEbrvyEt0OWwbzDIkGIbrVO00YTgy6pXa',
      },
      params: {},
      bodyType: BodyType.X_WWW_FORM_URL_ENCODED,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? subscription(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
  static String? status(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].status''',
      ));
  static String? packageName(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data[0].items.data[0].plan.product''',
      ));
  static int? endDate(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[0].current_period_end''',
      ));
  static int? startDate(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[0].current_period_start''',
      ));
  static String? subId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[0].id''',
      ));
}

class CustomerRetrivalCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'customerRetrival',
      apiUrl: 'https://api.stripe.com/v1/customers/cus_P5fYV8nF7Q6vIG',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer ' + 'sk_live_' + '51QDNJtGbVS90B1TZqqEBlppExttfUubMy4vCvljfBQ664G7ltvebhNtDlW8pGfRRYTEbrvyEt0OWwbzDIkGIbrVO00YTgy6pXa',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class PackageNameCall {
  static Future<ApiCallResponse> call({
    String? productid = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'PackageName',
      apiUrl: 'https://api.stripe.com/v1/products/${productid}',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer ' + 'sk_live_' + '51QDNJtGbVS90B1TZqqEBlppExttfUubMy4vCvljfBQ664G7ltvebhNtDlW8pGfRRYTEbrvyEt0OWwbzDIkGIbrVO00YTgy6pXa',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic name(dynamic response) => getJsonField(
        response,
        r'''$.name''',
      );
}

class DeletesubCall {
  static Future<ApiCallResponse> call({
    String? subid = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'deletesub',
      apiUrl: 'https://api.stripe.com/v1/subscriptions/${subid}',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization':
            'Bearer ' + 'sk_live_' + '51QDNJtGbVS90B1TZqqEBlppExttfUubMy4vCvljfBQ664G7ltvebhNtDlW8pGfRRYTEbrvyEt0OWwbzDIkGIbrVO00YTgy6pXa',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}
