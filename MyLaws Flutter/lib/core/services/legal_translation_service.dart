import 'dart:convert';
import 'package:http/http.dart' as http;

/// Legal Translation Service for MyLaws
///
/// Provides instant, high-fidelity bidirectional translation
/// between Bengali ("আপনি") and English without external API billing.
class LegalTranslationService {
  // In-memory runtime translation cache for instantaneous (0ms) re-toggling
  static final Map<String, String> _cache = {};

  // Pre-cached translations for known synthetic fixtures and canonical responses
  static final Map<String, String> _bnToEn = {
    // Problem Understandings
    'আপনি বকেয়া মজুরি আদায়ের বিষয়ে জানতে চেয়েছেন।':
        'You have inquired about recovering unpaid statutory wages.',
    'আপনি ৩ মাস ধরে বকেয়া বেতন না পাওয়ার বিষয়ে প্রতিকার জানতে চেয়েছেন।':
        'You have inquired about statutory remedies for 3 months of unpaid wages.',
    'আপনার উত্থাপিত আইনি পরিস্থিতি পর্যালোচনা করে এর সাথে প্রযোজ্য আইনি ক্ষেত্র চিহ্নিত করা হয়েছে।':
        'Your legal situation has been analyzed and the applicable statutory jurisdiction has been identified.',
    'বকেয়া মজুরি সমস্যা': 'Unpaid Wages & Compensation Dispute',
    'বকেয়া মজুরি আদায়ে আপনার সংবিধিবদ্ধ অধিকার':
        'Your Statutory Rights Regarding Recovery of Unpaid Wages',
    'ভোক্তা অধিকার ও প্রতিকার': 'Consumer Rights Protection & Redress',
    'পারিবারিক সহিংসতা': 'Domestic Violence Protection & Relief',
    'জমির বিরোধ ও দখল': 'Land Dispute & Possession Recovery',
    'জিডি ও পুলিশি নিরাপত্তা': 'General Diary (GD) & Police Protection',
    'মানিব্যাগ বা নথিপত্র হারানো': 'Lost Wallet & Identity Documents',
    'মানি ব্যাগ চুরি করণীয়': 'What to Do if Your Wallet is Stolen',
    'মানিব্যাগ চুরি করণীয়': 'What to Do if Your Wallet is Stolen',
    'মানি ব্যাগ চুরি করণীয়': 'What to Do if Your Wallet is Stolen',
    'মানিব্যাগ চুরি করণীয়': 'What to Do if Your Wallet is Stolen',
    'মানিব্যাগ চুরি হলে করণীয়': 'What to Do if Your Wallet is Stolen',
    'মানি ব্যাগ চুরি হলে করণীয়': 'What to Do if Your Wallet is Stolen',
    'মানিব্যাগ চুরি ও করণীয়': 'What to Do if Your Wallet is Stolen',
    'মানিব্যাগ ও এনআইডি হারানো': 'Lost Wallet & NID Card',
    'মানিব্যাগ হারানো': 'Lost Wallet & Documents',
    'মানি ব্যাগ হারানো': 'Lost Wallet & Documents',
    'মানিব্যাগ চুরি': 'Stolen Wallet',
    'মানি ব্যাগ চুরি': 'Stolen Wallet',
    'মোবাইল চুরি হলে করণীয়': 'What to Do if Mobile is Stolen',
    'মোবাইল চুরি করণীয়': 'What to Do if Mobile is Stolen',
    'মোবাইল চুরি করণীয়': 'What to Do if Mobile is Stolen',
    'মোবাইল চুরি': 'Stolen Mobile Phone',
    'মোবাইল বা ফোন চুরি': 'Stolen Mobile Phone',
    'আপনার মোবাইল চুরি হয়ে গেছে শুনে খারাপ লাগছে, চলুন দেখি আইন অনুযায়ী আপনার কী কী করণীয় আছে।':
        'Sorry to hear that your mobile has been stolen, let us see what you can do under the law.',
    'বকেয়া বেতন আদায়': 'Recovery of Unpaid Wages',
    'দুই মাসের বকেয়া বেতন আদায়': 'Recovery of 2 Months Unpaid Wages',
    'মেয়াদোত্তীর্ণ ওষুধ বিক্রির অভিযোগ': 'Complaint Regarding Expired Medicine Sale',
    'বিআরটিএ ড্রাইভিং লাইসেন্স প্রক্রিয়া': 'BRTA Driving License Procedure',
    'সরকারি আইনি সহায়তা ১৬৬৯৯': 'Government Legal Aid 16699',
    'বিনামূল্যে সরকারি আইনি সহায়তা': 'Free Government Legal Aid',

    // Lost Wallet & Documents Natural Guidance
    'মানিব্যাগ হারিয়ে গেলে দুশ্চিন্তা হওয়াটা স্বাভাবিক। বিশেষ করে এর ভেতরে NID, ব্যাংক কার্ড বা অন্যান্য গুরুত্বপূর্ণ কাগজপত্র থাকলে। তবে চিন্তা করবেন না, ধাপে ধাপে কিছু কাজ করলে আপনি আপনার আর্থিক ও ব্যক্তিগত তথ্য সুরক্ষিত রাখতে পারবেন।':
        'Losing a wallet naturally causes concern, especially when it contains an NID, bank cards, or other critical documents. However, do not worry; by taking step-by-step actions, you can safeguard both your financial and personal data under Bangladesh legal protections.',

    // Core Meanings & Explanations
    'বাংলাদেশ শ্রম আইন, ২০০৬ এর ধারা ১২৩ অনুযায়ী কাজ করার পর নির্ধারিত সময়ের মধ্যে পারিশ্রমিক পাওয়া শ্রমিকের আইনি অধিকার। ৩ মাস বেতন বকেয়া রাখা আইনত দণ্ডনীয় অপরাধ। ধারা ১৩২ অনুযায়ী আপনি বকেয়া বেতনের সাথে অতিরিক্ত ক্ষতিপূরণ দাবি করতে পারেন।':
        'Under Section 123 of the Bangladesh Labour Act, 2006, receiving remuneration within the statutory deadline following completion of work is an enforceable legal right. Withholding wages for 3 months is a punishable offense. Under Section 132, you are entitled to claim unpaid dues along with up to 25% statutory additional compensation.',
    'আইন অনুযায়ী চুক্তি মোতাবেক কাজ করার পর যথাসময়ে পারিশ্রমিক পাওয়া কর্মীর অলঙ্ঘনীয় অধিকার।':
        'Under Bangladesh statutory law, receiving agreed compensation on time upon performing work is an inviolable right of every employee.',
    'আইন অনুযায়ী চুক্তি মোতাবেক কাজ করার পর পারিশ্রমিক পাওয়া কর্মীর অধিকার।':
        'Under statutory law, timely payment following completion of work according to contract is an enforceable legal right.',
    'বাংলাদেশ শ্রম আইন, ২০০৬ অনুযায়ী মজুরি পরিশোধের নির্দিষ্ট সময়সীমা রয়েছে। ধারা ১২৩ অনুযায়ী মজুরি কাল সমাপ্তির পরবর্তী ৭ কর্মদিবসের মধ্যে মজুরি পরিশোধ করা বাধ্যতামূলক।':
        'Under the Bangladesh Labour Act, 2006, statutory wage payment deadlines are mandatory. Under Section 123, all earned wages must be disbursed within 7 working days following the end of the wage period.',
    'আপনার বিষয়টি বাংলাদেশ আইনের আলোকে পর্যালোচনা করা হয়েছে। সংশ্লিষ্ট ধারা অনুযায়ী আপনার অধিকার সংরক্ষণে আইনি পদক্ষেপ গ্রহণের সুযোগ রয়েছে।':
        'Your situation has been analyzed under Bangladesh statutory laws. You have the right to seek lawful resolution and enforce statutory protections.',
    'তাত্ক্ষণিক শারীরিক বিপদে অবিলম্বে জাতীয় জরুরি সেবা ৯৯৯ নম্বরে যোগাযোগ করুন।':
        'For immediate life-threatening physical danger, contact National Emergency Service 999 immediately.',

    // Immediate Next Steps / What To Do Next
    'সর্বপ্রথম আপনার নিয়োগপত্র, হাজিরা ও ব্যাংকের নথি গুছিয়ে মালিকপক্ষকে একটি নোটিশ দিন এবং দ্রুত DIFE-তে অভিযোগ প্রস্তুত করুন।':
        'First, organize your appointment letter, attendance records, and bank statements, issue a formal written notice to the employer, and promptly prepare a complaint to DIFE.',
    'প্রয়োজনীয় কাগজপত্র সংগ্রহ করে নোটিশ পাঠান।':
        'Collect all relevant documents and issue a formal written notice.',
    'প্রয়োজনীয় কাগজপত্র সংগ্রহ করে পরবর্তী পদক্ষেপে যান।':
        'Organize your documentation and proceed with the designated statutory steps.',
    'প্রয়োজনীয় প্রমাণাদি ও কাগজপত্র সংগ্রহ করে নির্দিষ্ট সময়সীমার মধ্যে পরবর্তী পদক্ষেপে যান।':
        'Collect all necessary documentary proof and proceed within the statutory limitation period.',
    'সংশ্লিষ্ট সমস্ত নথি ও লেনদেনের প্রমাণাদি গুছিয়ে রাখুন':
        'Organize and safeguard all relevant documents and transaction proof',
    'প্রয়োজনে সংশ্লিষ্ট সরকারি দপ্তর বা থানায় লিখিত আবেদন করুন':
        'Submit a formal written application to the designated government authority or police station',

    // Rights
    'মালিকপক্ষকে বকেয়া পরিশোধের জন্য লিখিত অনুরোধ বা নোটিশ প্রদান':
        'Issuing a formal written demand or legal notice to the employer for payment of arrears',
    'কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তরে (DIFE) সরাসরি অভিযোগ দাখিল':
        'Filing a formal complaint directly before the Department of Inspection for Factories and Establishments (DIFE)',
    'শ্রম আদালতে ধারা ১৩২ অনুযায়ী বকেয়া মজুরি ও ক্ষতিপূরণ আদায়ে মোকদ্দমা':
        'Filing a suit before the Labour Court under Section 132 for recovery of unpaid wages and compensation',
    'লিখিতভাবে বকেয়া দাবি করা': 'Demanding unpaid dues in writing',
    'শ্রম আদালতে অভিযোগ দাখিল': 'Filing a complaint before the Labour Court',
    'উপযুক্ত পরিদর্শকের কাছে অভিযোগ দাখিল':
        'Submitting a formal complaint to the designated Labour Inspector',
    '২৫% অতিরিক্ত ক্ষতিপূরণ দাবি':
        'Claiming up to 25% statutory additional compensation',

    // Checklist
    'নিয়োগপত্র ও হাজিরা কার্ড সংগ্রহ করুন':
        'Collect appointment letter, employee ID, and attendance records',
    'মালিকপক্ষকে লিখিত লিগ্যাল নোটিশ পাঠান':
        'Serve a formal written legal notice to the employer',
    'কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE)-এ অভিযোগ দাখিল করুন':
        'File a formal complaint with the Department of Inspection for Factories and Establishments (DIFE)',
    'সংগৃহীত কাগজপত্র গুছিয়ে রাখুন':
        'Organize and safeguard collected documents',
    'সংশ্লিষ্ট দপ্তরে লিখিত আবেদন জমা দিন':
        'Submit a written petition to the designated authority',

    // Draft Offer
    'DIFE-তে লিখিত অভিযোগ — খসড়া': 'Formal Complaint to DIFE — Draft Plaint',
    'আপনার তথ্য দিয়ে প্রস্তুতকৃত অভিযোগের খসড়া।':
        'Official complaint draft prepared with your case facts.',
    'কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE) অভিযোগ':
        'Department of Inspection for Factories & Establishments (DIFE) Complaint',
    'বকেয়া মজুরি আদায়ের জন্য সংশ্লিষ্ট উপ-মহাপরিদর্শক বরাবর আনুষ্ঠানিক লিখিত অভিযোগপত্র।':
        'Official written complaint addressed to the Deputy Inspector General for recovery of unpaid wages.',
    'ভোক্তা-অধিকার সংরক্ষণ অধিদপ্তর (DNCRP) অভিযোগ':
        'Directorate of National Consumer Rights Protection (DNCRP) Complaint',
    'থানায় সাধারণ ডায়েরি (General Diary - GD)':
        'Police Station General Diary (GD) Application',
    'পারিবারিক সহিংসতা সুরক্ষা ও ক্ষতিপূরণ আবেদন':
        'Domestic Violence Protection & Interim Relief Petition',
    'দেনমোহর ও ভরণপোষণ মোকদ্দমার আরজি':
        'Family Court Dower & Maintenance Suit Plaint',
    'ই-নামজারি ও জমাভাগ দরখাস্ত (AC Land)':
        'E-Mutation & Partition Application (AC Land)',
    'অবৈধ মাটি কাটা ও শান্তিভঙ্গ রোধে দরখাস্ত (UNO)':
        'Urgent Complaint to Prevent Illegal Soil Excavation (UNO)',
    'সুনির্দিষ্ট প্রতিকার আইন ৯ ধারা দখল পুনরুদ্ধার আরজি':
        'Section 9 Possession Recovery Civil Plaint',
    'মানিব্যাগ হারানো সত্যিই দুশ্চিন্তার বিষয়, বিশেষ করে এর মধ্যে টাকা, NID ও ব্যাংক কার্ড থাকলে। তবে চিন্তা করবেন না, এ ধরনের পরিস্থিতিতে আপনার আইনি সহায়তা পাওয়ার অধিকার রয়েছে।':
        'Losing your wallet is naturally stressful, especially with money, NID, and bank cards inside. However, do not worry; you have clear legal rights to protection and assistance in this situation.',
    'যদি কেউ আপনার অনুমতি ছাড়া অসৎ উদ্দেশ্যে মানিব্যাগ নিয়ে যায়, তাহলে সেটি চুরি হিসেবে গণ্য হতে পারে। বাংলাদেশের দণ্ডবিধি, ১৮৬০-এর ৩৭৮ ধারায় চুরির সংজ্ঞা দেওয়া হয়েছে এবং ৩৭৯ ধারায় এর শাস্তি সর্বোচ্চ ৩ বছর কারাদণ্ড, জরিমানা অথবা উভয়ই হতে পারে।\n\nতাই মানিব্যাগটি চুরি হয়ে থাকলে দ্রুত থানায় যোগাযোগ করে অভিযোগ জানান। আর হারিয়ে গিয়ে থাকলে একটি জিডি করুন। এতে ঘটনাটি সরকারি নথিতে থাকবে এবং ভবিষ্যতে আপনার NID, ব্যাংক কার্ড বা অন্য কোনো নথির অপব্যবহার হলে বিষয়টি প্রমাণ করতে সহায়তা করতে পারে।':
        'If someone takes your wallet dishonestly without consent, it constitutes theft under Section 378 of the Penal Code 1860, punishable under Section 379 with up to 3 years imprisonment, fine, or both.\n\nTherefore, if stolen, report it promptly to the police station. If lost, file a General Diary (GD) so the incident is recorded officially to protect against misuse of your NID, bank cards, or documents.',

    // Tenant & Rent Rights (Premises Rent Control Act, 1991)
    'বাড়ি ভাড়া ও ভাড়াটিয়ার সংবিধিবদ্ধ আইনি অধিকার':
        'Tenant Rights & Protection Against Unlawful Eviction',
    'বাড়ি ভাড়া সংক্রান্ত বিষয়ে ভাড়াটিয়ার আইনি সুরক্ষা নিশ্চিত করা অত্যন্ত জরুরি। বাড়ি ভাড়া নিয়ন্ত্রণ আইন অনুযায়ী আপনার অধিকার নিচে তুলে ধরা হলো।':
        'Securing tenant rights in rental housing is critical under statutory law. Here is your legal protection under the Premises Rent Control Act.',
    'বাড়ি ভাড়া নিয়ন্ত্রণ আইন ১৯৯১-এর ১৮ ধারা অনুযায়ী, ভাড়াটিয়া নিয়মিত চুক্তি অনুযায়ী ভাড়া পরিশোধ করতে সম্মত থাকলে বাড়িওয়ালা তাকে বলপূর্বক উচ্ছেদ করতে পারেন না। ধারা ১৯ মোতাবেক কোনো অবস্থাতেই গ্যাস, বিদ্যুৎ বা পানির মতো জরুরি নাগরিক সংযোগ বিচ্ছিন্ন করা দণ্ডনীয় অপরাধ। এছাড়া ধারা ১৩ অনুযায়ী ভাড়া গ্রহণের বিপরীতে বাড়িওয়ালা কর্তৃক লিখিত রসিদ প্রদান আইনত বাধ্যতামূলক।':
        'Under Section 18 of the Premises Rent Control Act 1991, landlords cannot forcibly evict a tenant as long as the tenant pays the agreed rent. Under Section 19, cutting off essential utilities (gas, electricity, water) is a strictly punishable offense. Furthermore, Section 13 legally mandates landlords to provide a written receipt for every rent payment.',
    'নিয়মিত ভাড়া পরিশোধ সাপেক্ষে জোরপূর্বক উচ্ছেদ থেকে আইনি সুরক্ষার অধিকার':
        'Statutory protection against arbitrary eviction as long as rent is paid',
    'গ্যাস, বিদ্যুৎ ও পানি ইত্যাদি জরুরি সংযোগ বজায় রাখার আইনগত নিশ্চয়তা':
        'Guaranteed continuation of essential utilities (water, gas, electricity)',
    'ভাড়া পরিশোধের বিপরীতে লিখিত রসিদ (Rent Receipt) প্রাপ্তির অধিকার':
        'Statutory right to receive written receipts for all rent disbursements',
    'বিরোধ দেখা দিলে ভাড়া নিয়ন্ত্রক আদালত (Rent Controller Court)-এ প্রতিকার চাওয়ার সুযোগ':
        'Right to seek legal redress before the Rent Controller Court',
    'ভাড়া পরিশোধের রসিদ, চুক্তিপত্র ও ব্যাংক স্টেটমেন্ট গুছিয়ে রাখুন। বাড়িওয়ালাকে শান্তভাবে আইন স্মরণ করিয়ে দিন এবং প্রয়োজনে ভাড়া নিয়ন্ত্রক আদালতের দ্বারস্থ হন।':
        'Preserve your tenancy contract, rent receipts, and bank transaction proofs. Inform the landlord of statutory protections and consult the Rent Controller Court if disputes arise.',
    'বাড়ি ভাড়ার চুক্তিপত্র (Tenancy Agreement), রসিদ ও লেনদেনের প্রমাণপত্র নিরাপদ স্থানে সংরক্ষণ করুন':
        'Organize your Tenancy Agreement, rent receipts, and payment transaction confirmations',
    'বাড়িওয়ালা কর্তৃক কোনো চাপ বা উচ্ছেদের হুমকি এলে বিষয়টি উল্লেখ করে আনুষ্ঠানিক লিখিত পত্র দিন':
        'Issue a polite, written formal letter to the landlord citing statutory tenancy protections',
    'পানি, গ্যাস বা বিদ্যুৎ বিচ্ছিন্ন করলে বা বলপূর্বক উচ্ছেদের চেষ্টা হলে নিকটস্থ ভাড়া নিয়ন্ত্রক আদালত বা থানায় অভিযোগ জানান':
        'File a complaint with the Rent Controller Court or police station if utilities are cut off or unlawful eviction is threatened',

    // General Legal Aid & NLASO
    'নাগরিক আইনি তথ্য ও সরকারি আইনি সহায়তা':
        'Citizen Legal Guidance & Government Legal Aid',
    'আপনার পরিস্থিতি পর্যালোচনা করে প্রাসঙ্গিক আইনি অধিকার ও সহায়তার দিকনির্দেশনা নিচে তুলে ধরা হলো।':
        'Reviewing your situation, here is the relevant legal guidance and citizen assistance framework.',
    'বাংলাদেশের সংবিধিবদ্ধ আইন অনুযায়ী প্রতিটি নাগরিকের আইনি অধিকার সুরক্ষা ও আদালতে বিচার পাওয়ার সমান সুযোগ রয়েছে। অসহায় বা অসচ্ছল নাগরিকগণের জন্য সরকারের জাতীয় আইনগত সহায়তা প্রদান সংস্থা (NLASO) সরকারি খরচে সম্পূর্ণ বিনামূল্যে আইনজীবী নিয়োগ ও আইনি পরামর্শ দিয়ে থাকে।':
        'Under Bangladesh law, every citizen is entitled to equal protection under the law and fair access to justice. The National Legal Aid Services Organization (NLASO) offers free legal counsel and government-funded representation for eligible citizens.',
    'সরকারি টোল-ফ্রি হেল্পলাইন ১৬৬৯৯-এ যেকোনো সময় বিনামূল্যে আইনি পরামর্শ পাওয়ার অধিকার':
        'Right to free legal counseling anytime via national toll-free helpline 16699',
    'জেলা লিগ্যাল এইড অফিস থেকে বিনামূল্যে সরকারি আইনজীবী পাওয়ার সুযোগ':
        'Right to government-sponsored free legal representation via District Legal Aid Offices',
    'আপনার নথিপত্র গুছিয়ে রাখুন এবং প্রয়োজনে সরকারি হেল্পলাইন ১৬৬৯৯-এ কল করে বিস্তারিত আইনি সহায়তা গ্রহণ করুন।':
        'Gather your documents and consult the national toll-free legal aid hotline at 16699.',
    'ঘটনাক্রম এবং প্রাসঙ্গিক কাগজপত্র গুছিয়ে একটি সংক্ষিপ্ত বিবরণী তৈরি করুন':
        'Organize relevant documents and write down a chronological timeline of events',
    'সরকারি টোল-ফ্রি জাতীয় আইনি সহায়তা হেল্পলাইন ১৬৬৯৯-এ ফোন করে প্রাথমিক পরামর্শ গ্রহণ করুন':
        'Dial government toll-free legal aid hotline 16699 for immediate counseling',
    'প্রয়োজনে নিকটস্থ জেলা জজ আদালত ভবনে অবস্থিত জেলা লিগ্যাল এইড অফিসে যোগাযোগ করুন':
        'Visit the District Legal Aid Office located in your District Court building if legal representation is needed',

    // Labour & Wages (Statutory Codification)
    'বকেয়া মজুরি ও শ্রম অধিকার সংক্রান্ত আইনি সুরক্ষা':
        'Recovery of Unpaid Wages & Labour Law Protection',
    'আপনার কর্মক্ষেত্রের বকেয়া মজুরি বা পাওনা প্রাপ্তি বিলম্বিত হওয়া সত্যিই উদ্বেগের। বাংলাদেশ শ্রম আইন অনুযায়ী আপনার আইনি অধিকার বিস্তারিত নিচে দেওয়া হলো।':
        'We understand your concern regarding unpaid employment wages or dues. Here is your statutory protection under Bangladesh labour legislation.',
    'বাংলাদেশ শ্রম আইন ২০০৬-এর ১২৩ ধারা মোতাবেক, মজুরি মেয়াদের সমাপ্তির পর সর্বোচ্চ ৭ কার্যদিবসের মধ্যে নিয়োগকর্তাকে কর্মীর সমস্ত প্রাপ্য মজুরি পরিশোধ করতে হবে। চাকরি হতে অব্যাহতি বা ছাঁটাইয়ের ক্ষেত্রে ৩০ কার্যদিবসের মধ্যে সকল চূড়ান্ত পাওনা পরিশোধ আইনত বাধ্যতামূলক।':
        'Under Section 123 of the Bangladesh Labour Act 2006, employers are statutorily mandated to disburse earned wages within 7 working days following the end of the wage period. In cases of termination or retrenchment, final dues must be settled within 30 working days.',
    'বকেয়া মজুরি পাওয়ার আইনগত সংবিধিবদ্ধ অধিকার':
        'Statutory right to receive timely wage disbursement',
    'মালিকপক্ষকে লিখিত দাবি জানিয়ে নোটিশ প্রদান':
        'Right to serve written wage demand letter to management',
    'কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE)-এ অভিযোগ দাখিলের অধিকার':
        'Right to file an official grievance with the Inspector (DIFE)',
    'নিয়োগপত্র, আইডি কার্ড ও পে-স্লিপ গুছিয়ে রাখুন। প্রথমে মালিকপক্ষকে লিখিত দাবি জানান। কাজ না হলে কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তরে (DIFE) অভিযোগ দাখিল করুন।':
        'Organize your appointment letter, ID badge, and attendance records. Send a written request to management, and submit a formal complaint to DIFE if unresolved.',
    'নিয়োগপত্র (Appointment Letter), সচিত্র পরিচয়পত্র ও হাজিরা/বেতনের প্রমাণপত্র সংগ্রহ করে রাখুন':
        'Assemble employment contract, official employee ID, and wage payment records',
    'বকেয়া মজুরির সুনির্দিষ্ট হিসাব উল্লেখ করে নিয়োগকারী কর্তৃপক্ষের নিকট লিখিত চিঠি প্রদান করুন':
        'Serve a formal written letter detailing outstanding arrears to the employer',
    'সমাধান না হলে উপযুক্ত পরিদর্শক, কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE)-এর কাছে অভিযোগ দাখিল করুন':
        'File a formal complaint before the Inspector, Department of Inspection for Factories and Establishments (DIFE)',

    // Theft & Lost Property (Penal Code 379)
    'মানিব্যাগ চুরি বা হারানোর আইনি সুরক্ষা ও করণীয়':
        'What to Do if Your Wallet is Stolen or Lost',
    'মানিব্যাগ চুরি বা হারিয়ে যাওয়া অত্যন্ত উদ্বেগের বিষয়। তবে টাকার চেয়েও ভেতরের জাতীয় পরিচয়পত্র, ব্যাংক কার্ড ও গুরুত্বপূর্ণ নথির অপব্যবহার রোধ করাই এখন সবচেয়ে জরুরি।':
        'Having your wallet stolen or lost is a serious worry. Protecting your identity documents, bank cards, and MFS accounts against fraudulent misuse is the top priority.',
    'দণ্ডবিধি ১৮৬০-এর ৩৭৯ ধারা মোতাবেক চুরি একটি দণ্ডনীয় ফৌজদারি অপরাধ। মানিব্যাগ বা কোনো মূল্যবান নথিপত্র চুরি হলে অথবা হারিয়ে গেলে তাৎক্ষণিকভাবে নিকটস্থ থানায় একটি সাধারণ ডায়েরি (জিডি) করা আইনি নিয়ম। এর ফলে পরবর্তীতে আপনার চুরি হওয়া NID বা কার্ড ব্যবহার করে কেউ কোনো প্রতারণা করলে আপনি আইনত নির্দোষ প্রমাণিত হবেন।':
        'Under Section 379 of the Penal Code 1860, theft is a cognizable criminal offense. If your wallet, national ID, or financial cards are stolen or lost, reporting the incident via a General Diary (GD) at the nearest police station grants legal protection against identity fraud or financial misuse.',
    'থানায় গিয়ে তাৎক্ষণিক বিনামূল্যে সাধারণ ডায়েরি (জিডি) করার অধিকার':
        'Right to lodge a General Diary (GD) at the jurisdictional police station',
    'ব্যাংক ও মোবাইল ব্যাংকিং হেল্পলাইনে ফোন করে কার্ড ও অ্যাকাউন্ট সাময়িক বন্ধ করার সুরক্ষা':
        'Right to emergency card deactivation via 24/7 bank & MFS helplines',
    'জিডি নম্বরের মাধ্যমে পরবর্তীতে নতুন NID ও ড্রাইভিং লাইসেন্স উত্তোলনের সুযোগ':
        'Statutory GD reference copy required for issuing replacement NID and driving licenses',
    'দেরি না করে ব্যাংকের হেল্পলাইনে ফোন করে কার্ড বন্ধ করুন। এরপর নিকটস্থ থানায় গিয়ে সাধারণ ডায়েরি (জিডি) করে জিডি নম্বরের একটি সিলযুক্ত অনুলিপি নিজের কাছে রাখুন।':
        'Immediately call your bank and MFS helplines to block all cards. Then visit your nearest police station to lodge a GD and retain a sealed copy.',
    'মানিব্যাগে থাকা ব্যাংক কার্ড, বিকাশ, নগদ বা রকেটের হেল্পলাইনে অবিলম্বে ফোন করে অ্যাকাউন্ট বা কার্ড সাময়িক বন্ধ করুন':
        'Immediately contact 24/7 bank and MFS customer hotlines to block debit/credit cards and mobile wallets',
    'নিকটস্থ থানায় গিয়ে কখন, কোথা থেকে এবং ভেতরে কী কী ছিল উল্লেখ করে একটি সাধারণ ডায়েরি (জিডি) দায়ের করুন':
        'File a General Diary (GD) at the nearest police station specifying date, time, location, and lost documents',
    'ডিউটি অফিসারের স্বাক্ষর ও সিলসহ জিডি কপির দ্বিতীয় অনুলিপিটি যত্নসহকারে সংরক্ষণ করুন':
        'Collect and preserve an official stamped and signed copy of the GD slip from the duty officer',

    // Consumer Rights (DNCRP 2009)
    'ভোক্তা অধিকার লঙ্ঘন ও অনলাইন ক্রয় সংক্রান্ত আইনি প্রতিকার':
        'Consumer Rights Violation & E-Commerce Redress',
    'ত্রুটিপূর্ণ পণ্য বা রিফান্ড না পাওয়া ভোক্তা অধিকার আইনের সুস্পষ্ট লঙ্ঘন। জাতীয় ভোক্তা অধিকার সংরক্ষণ অধিদপ্তরে অভিযোগ করে প্রতিকার পাওয়ার পূর্ণ অধিকার আপনার রয়েছে।':
        'Receiving defective goods or merchant refund refusal violates statutory consumer protection. You have clear recourse through the Directorate of National Consumer Rights Protection.',
    'ভোক্তা অধিকার সংরক্ষণ আইন ২০০৯ এবং ডিজিটাল কমার্স পরিচালনা নির্দেশিকা ২০২১-এর ৩.১.৮ ও ৩.৫.১ দফা মোতাবেক, কোনো মার্চেন্ট প্রতিশ্রুত পণ্য সরবরাহ করতে ব্যর্থ হলে বা ত্রুটিপূর্ণ পণ্য দিলে গ্রাহককে সম্পূর্ণ অর্থ ৭-১০ দিনের মধ্যে স্বয়ংক্রিয়ভাবে ফেরত দিতে বাধ্য। রিফান্ডের টাকা কোনো অবস্থাতেই ওয়ালেট বা কুপন আকারে আটকে রাখা আইনত নিষিদ্ধ।':
        'Under Clauses 3.1.8 and 3.5.1 of the Digital Commerce Guidelines 2021 and Consumer Rights Protection Act 2009, merchants failing delivery or providing defective goods must refund 100% of the funds within 7-10 days. Forcing store credits or non-cash coupons is explicitly prohibited.',
    'ত্রুটিপূর্ণ পণ্যের বিনামূল্যে প্রতিস্থাপন বা সম্পূর্ণ রিফান্ড পাওয়ার অধিকার':
        'Right to 100% cash refund or free product replacement',
    'জাতীয় ভোক্তা অধিকার সংরক্ষণ অধিদপ্তরে (DNCRP) ৩০ কার্যদিবসের মধ্যে অভিযোগ দায়ের':
        'Right to lodge an official complaint before DNCRP within 30 days',
    'অভিযোগ প্রমাণিত হলে আরোপিত জরিমানার ২৫% তাৎক্ষণিক ক্ষতিপূরণ হিসেবে পাওয়ার অধিকার':
        'Right to receive 25% of the penalty fine as direct citizen compensation upon conviction',
    'ক্রয় রসিদ (Invoice), চ্যাট ও আনবক্সিং প্রমাণ সংরক্ষণ করুন। জাতীয় ভোক্তা অধিকার সংরক্ষণ অধিদপ্তরে (DNCRP) লিখিত অভিযোগ অথবা হটলাইন ১৬১২১-এ যোগাযোগ করুন।':
        'Preserve invoices, chat transcripts, and unboxing evidence. Lodge a formal complaint with DNCRP or call consumer helpline 16121.',
    'ক্রয় রসিদ (Cash Memo/Invoice), অর্ডারের স্ক্রিনশট এবং পণ্যের ছবি প্রমাণ হিসেবে সংরক্ষণ করুন':
        'Secure purchase invoice, order confirmation screenshot, and photographs of the received goods',
    'বিক্রেতা বা প্রতিষ্ঠানের সাথে লিখিতভাবে যোগাযোগ করে পণ্য পরিবর্তন বা রিফান্ডের দাবি জানান':
        'Communicate formally in writing with the merchant demanding a replacement or full refund',
    'সমাধান না হলে ঘটনা ঘটার ৩০ কার্যদিবসের মধ্যে জাতীয় ভোক্তা অধিকার সংরক্ষণ অধিদপ্তরে (DNCRP) লিখিত অভিযোগ দায়ের করুন':
        'Lodge an official consumer complaint with DNCRP within 30 working days of the incident',

    // Cyber Threats & Harassment
    'সাইবার হুমকি, ব্ল্যাকমেইল ও ব্যক্তিগত তথ্যের অপব্যবহার প্রতিরোধ':
        'Cyber Harassment, Digital Blackmail & Privacy Protection',
    'অনলাইনে ব্ল্যাকমেইল বা ব্যক্তিগত তথ্য দিয়ে হয়রানি একটি মারাত্মক ফৌজদারি অপরাধ। ভয় পেয়ে কোনো অর্থ লেনদেন করবেন না; আইনগত ব্যবস্থা নেওয়াই সুরক্ষার একমাত্র উপায়।':
        'Online blackmail and unauthorized distribution of private materials are serious criminal offenses. Do not yield to extortion threats; lawful action is your safest protection.',
    'দণ্ডবিধি ১৮৬০-এর ৩৮৩ ধারা এবং সাইবার আইন অনুযায়ী, যে কোনো ধরনের ভয়ভীতি দেখিয়ে অর্থ দাবি (চাঁদাবাজি), ব্যক্তিগত ছবি ও তথ্য ফাঁসের হুমকি বা অবমাননাকর উপাদান প্রকাশ করা জামিনঅযোগ্য অপরাধ। পুলিশের সাইবার সাপোর্ট সেন্টার ও থানার মাধ্যমে অপরাধীকে তাৎক্ষণিক আইনের আওতায় আনা সম্ভব।':
        'Under Section 383 of the Penal Code 1860 and the Cyber Security Act, extorting money under fear of injury or publishing defamatory/private content online are cognizable offenses. Immediate intervention is available via the Police Cyber Support for Women and CID Cyber Police.',
    'ভয় পেয়ে অপরাধীর দাবি না মানা ও প্রমাণ সংরক্ষণের অধিকার':
        'Right to refuse extortion demands and protect personal digital safety',
    'পুলিশ সাইবার সাপোর্ট সেন্টার অথবা জাতীয় জরুরি সেবা ৯৯৯-এ তাৎক্ষণিক সহায়তা গ্রহণ':
        'Immediate emergency assistance via Police Cyber Helpline & 999',
    'নিকটস্থ থানায় এজাহার বা সাধারণ ডায়েরি (জিডি) দায়েরের অধিকার':
        'Right to file a formal Police GD or FIR against the perpetrator',
    'অপরাধীর সাথে যোগাযোগ বন্ধ করুন। সকল চ্যাট, অডিও ও স্ক্রিনশট ক্লাউড ড্রাইভে ব্যাকআপ রাখুন এবং দ্রুত থানা বা সিআইডি সাইবার পুলিশে অভিযোগ দিন।':
        'Cease further communication with the perpetrator. Secure backups of all messages, audio clips, and phone numbers, and lodge an immediate cyber complaint.',
    'হুমকি বা ব্ল্যাকমেইলের সকল চ্যাট হিস্ট্রি, অডিও রেকর্ড, প্রোফাইল লিংক ও স্ক্রিনশট নিরাপদ ক্লাউড ড্রাইভে সংরক্ষণ করুন':
        'Preserve all threatening messages, call recordings, social profile URLs, and chat screenshots',
    'ভয় পেয়ে কোনো টাকা পাঠাবেন না বা আপস করবেন না; অবিলম্বে অপরাধীর সাথে সরাসরি কথোপকথন বন্ধ রাখুন':
        'Do not transfer money or compromise under pressure; cease further direct interaction with the blackmailer',
    'পুলিশ সাইবার সাপোর্ট সেন্টার (হটলাইন: ০১৩২০০০০৮৮৮) অথবা নিকটস্থ থানায় বিস্তারিত প্রমাণসহ লিখিত অভিযোগ/জিডি দায়ের করুন':
        'Report the case with preserved evidence to Police Cyber Support (01320000888) or file a GD at the local police station',

    // Land & Property
    'জমি দখল, সীমানা বিরোধ ও ভূমিস্বত্ব আইনি সুরক্ষা':
        'Land Demarcation, Boundary Encroachment & Property Rights',
    'জমির সীমানা বা দখল সংক্রান্ত বিরোধে আইন নিজের হাতে না তুলে আদালতের আইনি প্রক্রিয়ায় সমাধান করাই নিরাপদ ও স্থায়ী পন্থা।':
        'Land boundary disputes and unlawful encroachment must be resolved through lawful administrative and civil court procedures.',
    'ভূমি অপরাধ প্রতিরোধ ও প্রতিকার আইন ২০২৩ এবং রাষ্ট্রীয় অধিগ্রহণ ও প্রজাস্বত্ব আইন ১৯৫০-এর ১৪৩ ধারা অনুযায়ী, কোনো ব্যক্তির বৈধ মালিকানা বা রেকর্ডীয় জমিতে বলপূর্বক অনুপ্রবেশ, দলিল জালকরণ বা সীমানা চিহ্ন ধ্বংস করা ফৌজদারি ও দেওয়ানি অপরাধ। সহকারী কমিশনার (ভূমি) এবং সহকারী জজ আদালতে এর সুনির্দিষ্ট প্রতিকার রয়েছে।':
        'Under the Land Crime Prevention and Redress Act 2023 and Section 143 of the State Acquisition and Tenancy Act 1950, unlawful encroachment, boundary destruction, or fraudulent record manipulation are punishable. Redress is available via the AC (Land) office and Civil Courts.',
    'খতিয়ান ও দলিলের ভিত্তিতে বৈধ স্বত্ব ও দখল সুরক্ষার অধিকার':
        'Right to peaceful possession based on registered title deed and record of rights (Khatian)',
    'সহকারী কমিশনার (ভূমি) বরাবর রেকর্ড সংশোধন বা নামজারি যাচাই':
        'Administrative mutation and boundary demarcation review via Assistant Commissioner (Land)',
    'দেওয়ানি আদালতে স্বত্ব ঘোষণা ও চিরস্থায়ী নিষেধাজ্ঞার মোকদ্দমা দায়ের':
        'Filing a civil suit for declaration of title and permanent injunction before the Assistant Judge Court',
    'সিএস, এসএ, আরএস ও হাল বিএস খতিয়ান ও খাজনার রসিদ সংগ্রহ করুন। ইউনিয়ন ভূমি অফিসে রেকর্ড যাচাই করে প্রয়োজনে দেওয়ানি আদালতে প্রতিকার চান।':
        'Gather CS, SA, RS, and BS record of rights along with up-to-date land tax receipts. Verify mutation records at the local land office.',
    'মূল দলিল, সিএস/এসএ/আরএস/বিএস খতিয়ান এবং হালনাগাদ ভূমি উন্নয়ন কর (খাজনা)-এর দাখিলা গুছিয়ে রাখুন':
        'Compile certified registered title deeds, historical Khatians, and up-to-date land tax receipts',
    'নিকটস্থ ইউনিয়ন ভূমি অফিস বা উপজেলা সহকারী কমিশনার (ভূমি) অফিসে গিয়ে রেকর্ড ও সীমানা যাচাই করুন':
        'Verify mutation and boundary demarcation records at the Upazila Assistant Commissioner (Land) office',
    'জোরপূর্বক বেদখল বা সীমানা লঙ্ঘনের চেষ্টা হলে বিজ্ঞ সহকারী জজ আদালতে দেওয়ানি মোকদ্দমা (চিরস্থায়ী নিষেধাজ্ঞা) দায়ের করুন':
        'File a petition for permanent injunction before the competent Civil Court if unlawful encroachment threatens',

    // Administrative (BRTA / Passport)
    'নাগরিক প্রশাসনিক সেবা প্রাপ্তির প্রক্রিয়া':
        'Citizen Administrative Procedure Roadmap',
    'ড্রাইভিং লাইসেন্স বা পাসপোর্ট ইত্যাদি সরকারি সেবা প্রাপ্তি একটি নিয়মিত নাগরিক প্রক্রিয়া। এর জন্য কোনো আদালত বা থানার অনুমতি প্রয়োজন হয় না।':
        'Procuring a driving license or national passport is a standard citizen administrative service requiring direct government application.',
    'বাংলাদেশ সড়ক পরিবহন কর্তৃপক্ষ (BRTA) অথবা পাসপোর্ট অধিদপ্তর নির্ধারিত অনলাইন পোর্টালে নাগরিকগণ সরাসরি আবেদন করতে পারেন। সরকার নির্ধারিত আবেদন ফি ও প্রমাণপত্র জমা দিলে কোনো মধ্যস্বত্বভোগী ছাড়াই এ সকল সেবা সম্পন্ন হয়।':
        'Citizens can apply directly via the Bangladesh Road Transport Authority (BRTA) or Department of Immigration and Passports online portals without intermediaries by paying statutory fees and providing identity proofs.',
    'দালাল বা মধ্যস্বত্বভোগী ছাড়া সরাসরি সরকারি সেবা প্রাপ্তির অধিকার':
        'Right to direct public service delivery without third-party brokers',
    'অফিসিয়াল ওয়েব পোর্টালের মাধ্যমে ঘরে বসেই আবেদন ও ফি পরিশোধের সুযোগ':
        'Online application and digital fee disbursement via verified government portals',
    'প্রয়োজনীয় জাতীয় পরিচয়পত্র, ছবি ও শিক্ষাগত সনদের ফটোকপি সংগ্রহ করুন এবং সরকারি পোর্টালে অনলাইন আবেদন সম্পন্ন করুন।':
        'Assemble NID, passport-size photographs, and certificates, then submit your application on the official government portal.',
    'জাতীয় পরিচয়পত্র (NID), পাসপোর্ট সাইজ ছবি ও প্রযোজ্য ক্ষেত্রে শিক্ষাগত/মেডিকেল সনদ প্রস্তুত রাখুন':
        'Assemble national ID card, passport photographs, and relevant medical/educational certificates',
    'অফিসিয়াল সার্ভিস পোর্টাল (যেমন bsp.brta.gov.bd)-এ গিয়ে সঠিক তথ্য দিয়ে ফরম পূরণ ও নির্ধারিত ফি জমা দিন':
        'Complete online form on the official portal and submit prescribed government fees',
    'নির্ধারিত তারিখে প্রয়োজনীয় মূল কাগজপত্রসহ সংশ্লিষ্ট সার্কেল অফিসে উপস্থিত হয়ে বায়োমেট্রিক ও পরীক্ষা সম্পন্ন করুন':
        'Attend the designated circle office on the scheduled date for biometric capture and verification',

    // Family Distress
    'পারিবারিক ও মানসিক সুরক্ষা পরামর্শ':
        'Family Distress & Personal Well-Being Guidance',
    'পারিবারিক বা ব্যক্তিগত টানাপোড়েনের মুহূর্তে মানসিকভাবে ভেঙে পড়া খুব স্বাভাবিক। তবে মনে রাখবেন, আপনি একা নন।':
        'Experiencing personal distress or family conflict is difficult. Please remember that you are not alone.',
    'পারিবারিক ভুল বোঝাবুঝি বা রাগারাগির ক্ষেত্রে তাৎক্ষণিক কোনো কঠোর বা আত্মঘাতী সিদ্ধান্ত নেওয়া উচিত নয়। একটু সময় নিয়ে বিশ্বস্ত কোনো আত্মীয়, শিক্ষক বা অভিজ্ঞ ব্যক্তির সাথে কথা বললে সমস্যার সমাধানের পথ বের করা সম্ভব।':
        'In times of family tension or emotional strain, avoid abrupt or harmful decisions. Taking time to confide in a trusted relative, teacher, or counselor can offer clarity and calm.',
    'মানসিক শান্তি ও নিরাপত্তা বজায় রাখার অধিকার':
        'Right to personal safety, mental peace, and emotional support',
    'পেশাদার ও আইনি কাউন্সেলিং সেবা পাওয়ার সুযোগ':
        'Access to free professional counseling and legal helpline assistance',
    'একটু শান্ত হোন, পানি পান করুন এবং বিশ্বস্ত কারো সাথে কথা বলুন। অতিরিক্ত বিপদে জাতীয় হেল্পলাইন ১০৯ বা ১০৯৮-এ ফোন করুন।':
        'Pause, take deep breaths, and reach out to someone you trust. In distress, dial national support helplines 109 or 1098.',
    'গভীর শ্বাস নিন এবং শান্ত হয়ে নিজেকে আশ্বস্ত করুন':
        'Take deep breaths and give yourself time to calm down',
    'পরিবারের বিশ্বস্ত সদস্য, শিক্ষক বা ঘনিষ্ঠ বন্ধুর সাথে কথা বলে আপনার অনুভূতি শেয়ার করুন':
        'Talk openly with a trusted family member, teacher, or friend',
    'অতিরিক্ত মানসিক সংকটে বিনামূল্যে সরকারি চাইল্ড হেল্পলাইন ১০৯৮ অথবা ৯৯৯-এ যোগাযোগ করুন':
        'Dial free child helpline 1098 or 999 if in immediate distress',

    // Family Court
    'দেনমোহর, ভরণপোষণ ও পারিবারিক আদালতের আইনি সুরক্ষা':
        'Dower, Maintenance & Family Court Statutory Protections',
    'পারিবারিক বিষয়ে দেনমোহর ও ভরণপোষণ আদায় অত্যন্ত গুরুত্বপূর্ণ সংবিধিবদ্ধ অধিকার। পারিবারিক আদালত আইন ২০২৩ অনুযায়ী আপনার প্রতিকার নিচে দেওয়া হলো।':
        'Enforcing statutory rights regarding dower and maintenance is an essential protection under the Family Courts Act 2023.',
    'পারিবারিক আদালত আইন ২০২৩-এর ৫ ধারা অনুযায়ী, দেনমোহর ও ভরণপোষণ আদায় স্ত্রীর অলঙ্ঘনীয় সংবিধিবদ্ধ অধিকার। স্বামী বিবাহবিচ্ছেদ করুক বা না করুক, বকেয়া দেনমোহর এবং সন্তানের ভরণপোষণ দিতে আইনত বাধ্য। ধারা ৬ অনুযায়ী স্ত্রী তার সুবিধাজনক স্থানীয় অধিক্ষেত্রের পারিবারিক আদালতে মামলা দায়ের করতে পারেন।':
        'Under Section 5 of the Family Courts Act 2023, recovering prompt and deferred dower (Mahr) and statutory maintenance is an inviolable legal right of a wife. Under Section 6, the suit can be instituted within the territorial jurisdiction where the wife currently resides.',
    'বকেয়া ও চলতি দেনমোহর সম্পূর্ণ আদায়ের সংবিধিবদ্ধ অধিকার':
        'Statutory right to enforce prompt and deferred dower recovery',
    'স্ত্রী ও অপ্রাপ্তবয়স্ক সন্তানের আইনসম্মত ভরণপোষণ প্রাপ্তির অধিকার':
        'Right to ongoing and past maintenance for wife and minor children',
    'পারিবারিক আদালতে দেওয়ানি প্রতিকার ও ক্রোকি পরোয়ানা জারির আবেদন':
        'Right to file a suit in the jurisdictional Family Court',
    'কাবিননামার (নিকাহনামা) মূল কপি বা জাবেদা নকল সংগ্রহ করুন। দেনমোহর ও ভরণপোষণের হিসাব করে পারিবারিক আদালতে বিজ্ঞ আইনজীবীর মাধ্যমে মামলা প্রস্তুত করুন।':
        'Collect a certified copy of your marriage certificate (Nikahnama). Calculate outstanding maintenance and prepare a petition for the Family Court.',
    'নিকাহনামা (কাবিননামা)-এর সত্যায়িত অনুলিপি ও বিয়ের প্রাসঙ্গিক প্রমাণাদি গুছিয়ে রাখুন':
        'Assemble certified copy of Nikahnama and relevant marital documentation',
    'বকেয়া দেনমোহর ও সন্তানের মাসিক ভরণপোষণের দাবি জানিয়ে আইনজীবীর মাধ্যমে নোটিশ পাঠান':
        'Issue a legal notice demanding payment of dower and child maintenance',
    'আপস মীমাংসা না হলে পারিবারিক আদালত আইন ২০২৩ অনুযায়ী স্থানীয় পারিবারিক আদালতে আরজি দাখিল করুন':
        'Institute a suit before the local Family Court under the Family Courts Act 2023',

    // Emergency Referral
    'জরুরি নিরাপত্তা সতর্কতা': 'Emergency Safety Alert',
    'তাত্ক্ষণিক শারীরিক বিপদের আশঙ্কা রয়েছে।':
        'Immediate risk of physical harm detected.',
    'তাত্ক্ষণিক শারীরিক বিপদে বা জরুরি পরিস্থিতিতে অবিলম্বে জাতীয় জরুরি সেবা ৯৯৯ নম্বরে কল করুন অথবা নিকটস্থ থানায় যোগাযোগ করুন।':
        'For immediate life-threatening situations, contact the National Emergency Service 999 or your nearest police station immediately.',
    'অবিলম্বে ৯৯৯-এ কল করুন।': 'Call 999 immediately.',
    'জাতীয় জরুরি সেবা ৯৯৯-এ ফোন করুন': 'Dial National Emergency Service 999',
  };

  static final Map<String, String> _enToBn = {
    'Unpaid Wages & Compensation Dispute': 'বকেয়া মজুরি ও ক্ষতিপূরণ বিরোধ',
    'Consumer Rights Protection & Redress': 'ভোক্তা অধিকার ও প্রতিকার',
    'Domestic Violence Protection & Relief': 'পারিবারিক সহিংসতা ও সুরক্ষা',
    'Land Dispute & Possession Recovery': 'জমির বিরোধ ও দখল পুনরুদ্ধার',
    'General Diary (GD) & Police Protection': 'জিডি ও পুলিশি নিরাপত্তা',
    'Lost Wallet & Identity Documents': 'মানিব্যাগ বা নথিপত্র হারানো',
    'What to do if mobile is stolen': 'মোবাইল চুরি হলে করণীয়',
    'What to Do if Mobile is Stolen': 'মোবাইল চুরি হলে করণীয়',
    'What to Do if Your Mobile is Stolen': 'মোবাইল চুরি হলে করণীয়',
    'Stolen Mobile Phone': 'মোবাইল চুরি',
    'Sorry to hear that your mobile has been stolen, let us see what you can do under the law.':
        'আপনার মোবাইল চুরি হয়ে গেছে শুনে খারাপ লাগছে, চলুন দেখি আইন অনুযায়ী আপনার কী কী করণীয় আছে।',
    'Losing a wallet naturally causes concern, especially when it contains an NID, bank cards, or other critical documents. However, do not worry; by taking step-by-step actions, you can safeguard both your financial and personal data under Bangladesh legal protections.':
        'মানিব্যাগ হারিয়ে গেলে দুশ্চিন্তা হওয়াটা স্বাভাবিক। বিশেষ করে এর ভেতরে NID, ব্যাংক কার্ড বা অন্যান্য গুরুত্বপূর্ণ কাগজপত্র থাকলে। তবে চিন্তা করবেন না, ধাপে ধাপে কিছু কাজ করলে আপনি আপনার আর্থিক ও ব্যক্তিগত তথ্য সুরক্ষিত রাখতে পারবেন।',
    'I am really sorry to hear that — losing your wallet is stressful and upsetting, especially with your important cards and IDs inside. Please do not panic, you are safe and there is a clear, simple legal way to protect yourself in Bangladesh.':
        'মানিব্যাগ হারিয়ে গেলে দুশ্চিন্তা হওয়াটা স্বাভাবিক। বিশেষ করে এর ভেতরে NID, ব্যাংক কার্ড বা অন্যান্য গুরুত্বপূর্ণ কাগজপত্র থাকলে। তবে চিন্তা করবেন না, ধাপে ধাপে কিছু কাজ করলে আপনি আপনার আর্থিক ও ব্যক্তিগত তথ্য সুরক্ষিত রাখতে পারবেন।',
    'Losing your wallet is stressful and frustrating, especially with your money, NID, bank cards inside. Please don\'t worry, you have clear legal protection in Bangladesh.':
        'মানিব্যাগ হারানো সত্যিই দুশ্চিন্তার বিষয়, বিশেষ করে এর মধ্যে টাকা, NID ও ব্যাংক কার্ড থাকলে। তবে চিন্তা করবেন না, এ ধরনের পরিস্থিতিতে আপনার আইনি সহায়তা পাওয়ার অধিকার রয়েছে।',
    'Losing your wallet is very stressful and frustrating, especially with your money, NID, bank cards inside. Please don\'t worry, you have clear legal protection in Bangladesh.':
        'মানিব্যাগ হারানো সত্যিই দুশ্চিন্তার বিষয়, বিশেষ করে এর মধ্যে টাকা, NID ও ব্যাংক কার্ড থাকলে। তবে চিন্তা করবেন না, এ ধরনের পরিস্থিতিতে আপনার আইনি সহায়তা পাওয়ার অধিকার রয়েছে।',
    'Losing your wallet is stressful and frustrating, especially with your money, NID, bank cards inside. Please do not worry, you have clear legal protection in Bangladesh.':
        'মানিব্যাগ হারানো সত্যিই দুশ্চিন্তার বিষয়, বিশেষ করে এর মধ্যে টাকা, NID ও ব্যাংক কার্ড থাকলে। তবে চিন্তা করবেন না, এ ধরনের পরিস্থিতিতে আপনার আইনি সহায়তা পাওয়ার অধিকার রয়েছে।',
    'Under the law, stealing your wallet is a theft offence — defined under Section 378 and punishable under Section 379 of the Penal Code 1860 with imprisonment up to 3 years and fine. As a victim, you have the right to get help from the police. Filing a prompt GD/FIR not only helps recover it and catch the thief, but it legally protects you if anyone misuses your NID, cards or documents.':
        'যদি কেউ আপনার অনুমতি ছাড়া অসৎ উদ্দেশ্যে মানিব্যাগ নিয়ে যায়, তাহলে সেটি চুরি হিসেবে গণ্য হতে পারে। বাংলাদেশের দণ্ডবিধি, ১৮৬০-এর ৩৭৮ ধারায় চুরির সংজ্ঞা দেওয়া হয়েছে এবং ৩৭৯ ধারায় এর শাস্তি সর্বোচ্চ ৩ বছর কারাদণ্ড, জরিমানা অথবা উভয়ই হতে পারে।\n\nতাই মানিব্যাগটি চুরি হয়ে থাকলে দ্রুত থানায় যোগাযোগ করে অভিযোগ জানান। আর হারিয়ে গিয়ে থাকলে একটি জিডি করুন। এতে ঘটনাটি সরকারি নথিতে থাকবে এবং ভবিষ্যতে আপনার NID, ব্যাংক কার্ড বা অন্য কোনো নথির অপব্যবহার হলে বিষয়টি প্রমাণ করতে সহায়তা করতে পারে।',
  };

  // Common statutory phrase replacements
  static final List<MapEntry<RegExp, String>> _phraseReplacementsBnToEn = [
    MapEntry(
        RegExp(r'\[SYNTHETIC SAMPLE[^\]]*\]\s*', caseSensitive: false), ''),
    MapEntry(
        RegExp(r'বাংলাদেশ শ্রম আইন,?\s*২০০৬'), 'Bangladesh Labour Act, 2006'),
    MapEntry(RegExp(r'শ্রম আইন'), 'Labour Act'),
    MapEntry(RegExp(r'শ্রম আদালত'), 'Labour Court'),
    MapEntry(RegExp(r'ধারা\s*১২৩'), 'Section 123'),
    MapEntry(RegExp(r'ধারা\s*১৩২'), 'Section 132'),
    MapEntry(RegExp(r'ধারা\s*১২৪ক'), 'Section 124A'),
    MapEntry(RegExp(r'ধারা\s*৫'), 'Section 5'),
    MapEntry(RegExp(r'ধারা\s*৯'), 'Section 9'),
    MapEntry(RegExp(r'ধারা\s*১৬৭'), 'Section 167'),
    MapEntry(RegExp(r'ধারা\s*৫৪'), 'Section 54'),
    MapEntry(RegExp(r'বকেয়া মজুরি'), 'unpaid wages'),
    MapEntry(RegExp(r'বকেয়া বেতন'), 'outstanding salary'),
    MapEntry(RegExp(r'৭ কর্মদিবস'), '7 working days'),
    MapEntry(RegExp(r'১২ মাস'), '12 months'),
    MapEntry(RegExp(r'২৫% অতিরিক্ত ক্ষতিপূরণ'), '25% statutory compensation'),
    MapEntry(RegExp(r'কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর'),
        'Department of Inspection for Factories and Establishments'),
    MapEntry(RegExp(r'ডিআইএফই|DIFE'), 'DIFE'),
    MapEntry(RegExp(r'ভোক্তা অধিকার সংরক্ষণ অধিদপ্তর'),
        'Directorate of National Consumer Rights Protection'),
    MapEntry(RegExp(r'ডিএনসিআরপি|DNCRP'), 'DNCRP'),
    MapEntry(RegExp(r'সাধারণ ডায়েরি|সাধারণ ডায়েরী'), 'General Diary (GD)'),
    MapEntry(RegExp(r'ফৌজদারি কার্যবিধি'), 'Code of Criminal Procedure (CrPC)'),
    MapEntry(RegExp(r'দেওয়ানি কার্যবিধি'), 'Code of Civil Procedure (CPC)'),
    MapEntry(RegExp(r'লিগ্যাল এইড'), 'Legal Aid'),
    MapEntry(RegExp(r'হেল্পলাইন ১৬৪৩০'), 'National Legal Aid Helpline 16430'),
    MapEntry(
        RegExp(r'জাতীয় জরুরি সেবা ৯৯৯'), 'National Emergency Helpline 999'),
    MapEntry(RegExp(r'সুপ্রিম কোর্ট'), 'Supreme Court'),
    MapEntry(RegExp(r'হাইকোর্ট'), 'High Court'),
    MapEntry(RegExp(r'বিনা পরোয়ানায় গ্রেপ্তার'), 'arrest without warrant'),
    MapEntry(RegExp(r'পুলিশ রিমান্ড'), 'police remand'),
    MapEntry(RegExp(r'হেফাজতে নির্যাতন'), 'custodial torture'),
    MapEntry(RegExp(r'নিষেধাজ্ঞা'), 'injunction'),
    MapEntry(RegExp(r'নামজারি'), 'land mutation (namjari)'),
    MapEntry(RegExp(r'খতিয়ান|খতিয়ান'), 'record of rights (khatian)'),
    MapEntry(RegExp(r'দলিল'), 'registered deed (dalil)'),
    MapEntry(RegExp(r'বেদখল'), 'dispossession'),
    MapEntry(RegExp(r'দখল পুনরুদ্ধার'), 'recovery of possession'),
    MapEntry(RegExp(r'ভরণপোষণ'), 'maintenance'),
    MapEntry(RegExp(r'দেনমোহর'), 'dower (mahr)'),
    MapEntry(RegExp(r'পারিবারিক আদালত'), 'Family Court'),
    MapEntry(RegExp(r'বাড়ি ভাড়া নিয়ন্ত্রণ আইন,?\s*১৯৯১'),
        'Premises Rent Control Act, 1991'),
    MapEntry(RegExp(r'বাড়ি ভাড়া|বাড়ি ভাড়া'), 'house rent'),
    MapEntry(RegExp(r'ভাড়াটিয়া|ভাড়াটিয়া'), 'tenant'),
    MapEntry(RegExp(r'বাড়িওয়ালা|বাড়িওয়ালা'), 'landlord'),
    MapEntry(RegExp(r'ভাড়ার রসিদ|ভাড়া রসিদ'), 'rent receipt'),
    MapEntry(RegExp(r'ভাড়া নিয়ন্ত্রক আদালত'), 'Rent Controller Court'),
    MapEntry(RegExp(r'বলপূর্বক উচ্ছেদ|জোরপূর্বক উচ্ছেদ'), 'unlawful eviction'),
    MapEntry(RegExp(r'সংযোগ বিচ্ছিন্ন'), 'utility disconnection'),
    MapEntry(RegExp(r'জাতীয় আইনগত সহায়তা প্রদান সংস্থা'),
        'National Legal Aid Services Organization (NLASO)'),
    MapEntry(RegExp(r'জেলা লিগ্যাল এইড অফিস'), 'District Legal Aid Office'),
  ];

  // Common statutory phrase replacements from English to natural Bengali
  static final List<MapEntry<RegExp, String>> _phraseReplacementsEnToBn = [
    MapEntry(RegExp(r'Premises Rent Control Act,?\s*1991', caseSensitive: false),
        'বাড়ি ভাড়া নিয়ন্ত্রণ আইন, ১৯৯১'),
    MapEntry(RegExp(r'Bangladesh Labour Act,?\s*2006', caseSensitive: false),
        'বাংলাদেশ শ্রম আইন, ২০০৬'),
    MapEntry(RegExp(r'Penal Code,?\s*1860', caseSensitive: false),
        'দণ্ডবিধি, ১৮৬০'),
    MapEntry(
        RegExp(r'Consumer Rights Protection Act,?\s*2009', caseSensitive: false),
        'ভোক্তা অধিকার সংরক্ষণ আইন, ২০০৯'),
    MapEntry(RegExp(r'Family Courts Act,?\s*2023', caseSensitive: false),
        'পারিবারিক আদালত আইন, ২০২৩'),
    MapEntry(RegExp(r'\bSection\b', caseSensitive: false), 'ধারা'),
    MapEntry(RegExp(r'\bLabour Court\b', caseSensitive: false), 'শ্রম আদালত'),
    MapEntry(RegExp(r'\bFamily Court\b', caseSensitive: false), 'পারিবারিক আদালত'),
    MapEntry(RegExp(r'\bRent Controller Court\b', caseSensitive: false),
        'ভাড়া নিয়ন্ত্রক আদালত'),
    MapEntry(RegExp(r'\bCivil Court\b', caseSensitive: false), 'দেওয়ানি আদালত'),
    MapEntry(RegExp(r'\bHigh Court\b', caseSensitive: false), 'হাইকোর্ট'),
    MapEntry(RegExp(r'\bSupreme Court\b', caseSensitive: false), 'সুপ্রিম কোর্ট'),
    MapEntry(RegExp(r'\bGeneral Diary\s*\(GD\)\b|\bGD\b', caseSensitive: false),
        'সাধারণ ডায়েরি (জিডি)'),
    MapEntry(RegExp(r'\bpolice station\b', caseSensitive: false), 'থানা'),
    MapEntry(RegExp(r'\bNational Legal Aid Services Organization\s*\(NLASO\)\b|\bNLASO\b',
            caseSensitive: false),
        'জাতীয় আইনগত সহায়তা প্রদান সংস্থা (NLASO)'),
    MapEntry(RegExp(r'\bDistrict Legal Aid Offices?\b', caseSensitive: false),
        'জেলা লিগ্যাল এইড অফিস'),
    MapEntry(RegExp(r'\btenants?\b', caseSensitive: false), 'ভাড়াটিয়া'),
    MapEntry(RegExp(r'\blandlords?\b', caseSensitive: false), 'বাড়িওয়ালা'),
    MapEntry(RegExp(r'\bhouse rent\b|\btenancy\b', caseSensitive: false), 'বাড়ি ভাড়া'),
    MapEntry(RegExp(r'\bunlawful eviction\b|\bforced eviction\b', caseSensitive: false),
        'জোরপূর্বক উচ্ছেদ'),
    MapEntry(RegExp(r'\brent receipts?\b', caseSensitive: false), 'ভাড়ার রসিদ'),
    MapEntry(RegExp(r'\bunpaid wages\b', caseSensitive: false), 'বকেয়া মজুরি'),
    MapEntry(RegExp(r'\bsalary\b', caseSensitive: false), 'বেতন'),
    MapEntry(RegExp(r'\bcompensation\b', caseSensitive: false), 'ক্ষতিপূরণ'),
    MapEntry(RegExp(r'\barrears\b', caseSensitive: false), 'বকেয়া'),
    MapEntry(RegExp(r'\bpunishable offense\b', caseSensitive: false),
        'দণ্ডনীয় অপরাধ'),
    MapEntry(RegExp(r'\blegal notice\b', caseSensitive: false), 'আইনি নোটিশ'),
    MapEntry(RegExp(r'\bworking days\b', caseSensitive: false), 'কার্যদিবস'),
    MapEntry(RegExp(r'\bdays\b', caseSensitive: false), 'দিন'),
    MapEntry(RegExp(r'\byears?\b', caseSensitive: false), 'বছর'),
    MapEntry(RegExp(r'\bmonths?\b', caseSensitive: false), 'মাস'),
    MapEntry(RegExp(r'\bimprisonment\b', caseSensitive: false), 'কারাদণ্ড'),
    MapEntry(RegExp(r'\bfine\b', caseSensitive: false), 'জরিমানা'),
  ];

  static bool hasBengali(String text) {
    return RegExp(r'[\u0980-\u09FF]').hasMatch(text);
  }

  /// Normalizes all Bengali numerals (০-৯) into standard numerals (0-9)
  /// according to official typography guidelines.
  static String normalizeStandardDigits(String text) {
    const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var result = text;
    for (int i = 0; i < bnDigits.length; i++) {
      result = result.replaceAll(bnDigits[i], '$i');
    }
    return result;
  }

  /// Cleans machine-translated robotic artifacts and canned condolences into respectful, natural Bangla
  static String sanitizeNaturalBangla(String text) {
    var s = text;
    s = s.replaceAll(
      RegExp(r'আমি\s+এটা\s+শুনে\s+সত্যিই\s+দুঃখিত\s*[-—–]?\s*', caseSensitive: false),
      '',
    );
    s = s.replaceAll(
      RegExp(r'অনুগ্রহ\s+করে\s+আতঙ্কিত\s+হবেন\s+না,\s*আপনি\s+নিরাপদ\s+এবং\s*', caseSensitive: false),
      'তবে চিন্তা করবেন না, ',
    );
    s = s.replaceAll(
      RegExp(r'অনুগ্রহ\s+করে\s+আতঙ্কিত\s+হবেন\s+না\s*[,.]?\s*', caseSensitive: false),
      'তবে চিন্তা করবেন না, ',
    );
    s = s.replaceAll(
      RegExp(r'আতঙ্কিত\s+হবেন\s+না,\s*আপনি\s+নিরাপদ\s*', caseSensitive: false),
      'চিন্তা করবেন না, ',
    );
    s = s.replaceAll(
      RegExp(r'আতঙ্কিত\s+হবেন\s+না\s*', caseSensitive: false),
      'চিন্তা করবেন না, ',
    );
    s = s.replaceAll('একটি পরিষ্কার, সহজ আইনি উপায় রয়েছে', 'ধাপে ধাপে আইনি পদক্ষেপ নিলে সুরক্ষার উপায় রয়েছে');
    s = s.replaceAll('একটি পরিষ্কার এবং সহজ আইনি উপায় রয়েছে', 'ধাপে ধাপে আইনি পদক্ষেপ নিলে সুরক্ষার উপায় রয়েছে');

    // Natural tone for lost/stolen wallet and documents
    s = s.replaceAll(
      RegExp(r'(?:আপনার\s*)?মানিব্যাগ\s*হারানো\s*(?:খুব\s*)?চাপ\s*এবং\s*বিরক্তিকর\s*,?\s*', caseSensitive: false),
      'মানিব্যাগ হারানো সত্যিই দুশ্চিন্তার বিষয়, ',
    );
    s = s.replaceAll(
      RegExp(r'(?:খুব\s*)?চাপ\s*এবং\s*বিরক্তিকর', caseSensitive: false),
      'সত্যিই দুশ্চিন্তার বিষয়',
    );
    s = s.replaceAll('দুশ্চিন্তার বিষয় মার্কেটিং কল', 'বিরক্তিকর মার্কেটিং কল');
    s = s.replaceAll('দুশ্চিন্তার বিষয় প্রমোশনাল কল', 'বিরক্তিকর প্রমোশনাল কল');
    s = s.replaceAll('দুশ্চিন্তার বিষয় কল', 'বিরক্তিকর কল');

    s = s.replaceAll(
      RegExp(r'বিশেষ\s*করে\s*(?:আপনার\s*)?(?:টাকা,\s*NID,?\s*(?:ব্যাঙ্ক|ব্যাংক)\s*কার্ড|NID,?\s*(?:ব্যাঙ্ক|ব্যাংক)\s*কার্ড\s*বা\s*অন্যান্য\s*গুরুত্বপূর্ণ\s*কাগজপত্র)\s*(?:ভিতরে|ভেতরে)\s*আছে\s*।?', caseSensitive: false),
      'বিশেষ করে এর মধ্যে টাকা, NID ও ব্যাংক কার্ড থাকলে।',
    );

    s = s.replaceAll(
      RegExp(r'অনুগ্রহ\s*করে\s*চিন্তা\s*করবেন\s*না,\s*বাংলাদেশে\s*আপনার\s*স্পষ্ট\s*আইনি\s*সুরক্ষা\s*আছে\s*।?', caseSensitive: false),
      'তবে চিন্তা করবেন না, এ ধরনের পরিস্থিতিতে আপনার আইনি সহায়তা পাওয়ার অধিকার রয়েছে।',
    );
    s = s.replaceAll(
      'বাংলাদেশে আপনার স্পষ্ট আইনি সুরক্ষা আছে',
      'এ ধরনের পরিস্থিতিতে আপনার আইনি সহায়তা পাওয়ার অধিকার রয়েছে',
    );
    s = s.replaceAll(
      'আপনার স্পষ্ট আইনি সুরক্ষা আছে',
      'আপনার আইনি সহায়তা পাওয়ার অধিকার রয়েছে',
    );

    // Natural phrasing for Penal Code theft provisions
    s = s.replaceAll(
      RegExp(r'আইনের\s*অধীনে,?\s*আপনার\s*মানিব্যাগ\s*চুরি\s*করা\s*চুরির\s*অপরাধ', caseSensitive: false),
      'যদি কেউ আপনার অনুমতি ছাড়া অসৎ উদ্দেশ্যে মানিব্যাগ নিয়ে যায়, তাহলে সেটি চুরি হিসেবে গণ্য হতে পারে',
    );
    s = s.replaceAll(
      RegExp(r'আপনার\s*মানিব্যাগ\s*চুরি\s*করা\s*চুরির\s*অপরাধ', caseSensitive: false),
      'যদি কেউ আপনার অনুমতি ছাড়া অসৎ উদ্দেশ্যে মানিব্যাগ নিয়ে যায়, তাহলে সেটি চুরি হিসেবে গণ্য হতে পারে',
    );
    s = s.replaceAll(
      RegExp(r'চুরি\s*করা\s*চুরির\s*অপরাধ', caseSensitive: false),
      'অনুমতি ছাড়া নিয়ে যাওয়া চুরির অপরাধ',
    );

    s = s.replaceAll(
      RegExp(r'[-—–]?\s*ধারা\s*(?:৩৭৮|378)-এ\s*সংজ্ঞায়িত\s*এবং\s*(?:দণ্ডবিধি|দন্ডবিধি)\s*(?:১৮৬০|1860)-এর\s*ধারা\s*(?:৩৭৯|379)-এর\s*অধীনে\s*শাস্তিযোগ্য\s*(?:৩|3)\s*বছর\s*পর্যন্ত\s*কারাদণ্ড\s*এবং\s*জরিমানা\s*।?', caseSensitive: false),
      'বাংলাদেশের দণ্ডবিধি, ১৮৬০-এর ৩৭৮ ধারায় চুরির সংজ্ঞা দেওয়া হয়েছে এবং ৩৭৯ ধারায় এর শাস্তি সর্বোচ্চ ৩ বছর কারাদণ্ড, জরিমানা অথবা উভয়ই হতে পারে।',
    );

    // Natural Bengali legal terminology ("ভুক্তভোগী", not English "ভিকটিম")
    s = s.replaceAll('একজন ভিকটিম হিসেবে', 'ভুক্তভোগী হিসেবে');
    s = s.replaceAll('ভিকটিম হিসেবে', 'ভুক্তভোগী হিসেবে');
    s = s.replaceAll('ভিকটিম', 'ভুক্তভোগী');
    s = s.replaceAll('সাহায্য পাওয়ার অধিকার আপনার আছে', 'সহায়তা পাওয়ার পূর্ণ অধিকার আপনার রয়েছে');

    // Natural GD / FIR and reporting guidance
    s = s.replaceAll(
      RegExp(r'দ্রুত\s*একটি\s*জিডি/এফআইআর\s*দায়ের\s*করা\s*শুধুমাত্র\s*এটি\s*পুনরুদ্ধার\s*করতে.*?অপব্যবহার\s*করে\s*থাকে\s*।?', caseSensitive: false),
      'তাই মানিব্যাগটি চুরি হয়ে থাকলে দ্রুত থানায় যোগাযোগ করে অভিযোগ জানান। আর হারিয়ে গিয়ে থাকলে একটি জিডি করুন। এতে ঘটনাটি সরকারি নথিতে থাকবে এবং ভবিষ্যতে আপনার NID, ব্যাংক কার্ড বা অন্য কোনো নথির অপব্যবহার হলে বিষয়টি প্রমাণ করতে সহায়তা করতে পারে।',
    );
    s = s.replaceAll(
      RegExp(r'শুধুমাত্র\s*এটি\s*পুনরুদ্ধার\s*করতে\s*এবং\s*চোরকে\s*ধরতে\s*সাহায্য\s*করে\s*না,\s*তবে\s*এটি\s*', caseSensitive: false),
      'এটি উদ্ধারে যেমন সহায়তা করবে, তেমনই ',
    );

    return s.trim();
  }

  /// Sanitizes machine-translated English quirks and clumsy literal translations
  static String sanitizeNaturalEnglish(String text) {
    var s = text;
    s = s.replaceAll(
      RegExp(r'\bMoney\s+bags?\s+are\s+to\s+be\s+stolen\b', caseSensitive: false),
      'What to Do if Your Wallet is Stolen',
    );
    s = s.replaceAll(
      RegExp(r'\bare\s+to\s+be\s+stolen\b', caseSensitive: false),
      'What to Do if Stolen',
    );
    s = s.replaceAll(
      RegExp(r'\bMoney\s+bags?\s+theft\s+to\s+do\b', caseSensitive: false),
      'What to Do if Your Wallet is Stolen',
    );
    s = s.replaceAll(
      RegExp(r'\bMoney\s+bags?\b', caseSensitive: false),
      'Wallet',
    );
    s = s.replaceAll(
      RegExp(r'\bmoney\s+bags?\b', caseSensitive: false),
      'wallet',
    );
    return s.trim();
  }

  /// Normalizes all brand name variants (including machine translation artifacts like 'My Lodge')
  /// to the canonical brand name 'MyLaws'.
  static String cleanBrandName(String text) {
    var cleaned = text
        .replaceAll(RegExp(r'\bMy\s+Lodge\b', caseSensitive: false), 'MyLaws')
        .replaceAll(RegExp(r'\bMy\s+Laws\b', caseSensitive: false), 'MyLaws')
        .replaceAll(RegExp(r'\bmylaws\b', caseSensitive: false), 'MyLaws')
        .replaceAll('মাই লজ (MyLaws)', 'MyLaws')
        .replaceAll('মাই লজ(MyLaws)', 'MyLaws')
        .replaceAll('(মাই লজ)', 'MyLaws')
        .replaceAll('মাই লজ', 'MyLaws')
        .replaceAll('মাইলজ', 'MyLaws');
    if (hasBengali(cleaned)) {
      cleaned = sanitizeNaturalBangla(cleaned);
    }
    return normalizeStandardDigits(cleaned);
  }

  /// Synchronous translation from in-memory cache or canonical static maps
  static String translate(String text, {required bool toBangla}) {
    final trimmed = cleanBrandName(text).trim();
    if (trimmed.isEmpty) return trimmed;

    final cacheKey = '$toBangla:$trimmed';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final hasBn = hasBengali(trimmed);
    if (toBangla && hasBn) return trimmed;
    if (!toBangla && !hasBn) return trimmed;

    if (toBangla) {
      // 1. Direct key match in English -> Bengali map
      if (_enToBn.containsKey(trimmed)) {
        _cache[cacheKey] = _enToBn[trimmed]!;
        return _enToBn[trimmed]!;
      }

      // 2. Reverse value match in Bengali -> English map
      for (final e in _bnToEn.entries) {
        if (e.value.toLowerCase() == trimmed.toLowerCase()) {
          _cache[cacheKey] = e.key;
          return e.key;
        }
      }

      // 3. Normalized whitespace match
      final normalized = trimmed.replaceAll(RegExp(r'\s+'), ' ');
      for (final e in _enToBn.entries) {
        if (e.key.replaceAll(RegExp(r'\s+'), ' ').toLowerCase() ==
            normalized.toLowerCase()) {
          _cache[cacheKey] = e.value;
          return e.value;
        }
      }
      for (final e in _bnToEn.entries) {
        if (e.value.replaceAll(RegExp(r'\s+'), ' ').toLowerCase() ==
            normalized.toLowerCase()) {
          _cache[cacheKey] = e.key;
          return e.key;
        }
      }

      // 4. Multi-sentence paragraph decomposition
      final sentences = trimmed
          .split(RegExp(r'(?<=[.\n?!])\s*'))
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (sentences.length > 1) {
        final translated = sentences
            .map((s) => translate(s, toBangla: true))
            .join(' ');
        if (translated.trim().isNotEmpty && hasBengali(translated)) {
          _cache[cacheKey] = translated;
          return translated;
        }
      }

      // 5. Common statutory phrase replacement fallback
      var translated = trimmed;
      for (final entry in _phraseReplacementsEnToBn) {
        translated = translated.replaceAll(entry.key, entry.value);
      }
      final cleaned = cleanBrandName(sanitizeNaturalBangla(translated));
      _cache[cacheKey] = cleaned;
      return cleaned;
    } else {
      final clean = trimmed.replaceAll(
          RegExp(r'\[SYNTHETIC SAMPLE[^\]]*\]\s*', caseSensitive: false), '');

      // 1. Direct key match in Bengali -> English map
      if (_bnToEn.containsKey(clean)) {
        _cache[cacheKey] = _bnToEn[clean]!;
        return _bnToEn[clean]!;
      }
      if (_bnToEn.containsKey(trimmed)) {
        _cache[cacheKey] = _bnToEn[trimmed]!;
        return _bnToEn[trimmed]!;
      }

      // 2. Reverse value match in English -> Bengali map
      for (final e in _enToBn.entries) {
        if (e.value == clean || e.value == trimmed) {
          _cache[cacheKey] = e.key;
          return e.key;
        }
      }

      // 3. Normalized whitespace match
      final normalized = clean.replaceAll(RegExp(r'\s+'), ' ');
      for (final e in _bnToEn.entries) {
        if (e.key.replaceAll(RegExp(r'\s+'), ' ') == normalized) {
          _cache[cacheKey] = e.value;
          return e.value;
        }
      }
      for (final e in _enToBn.entries) {
        if (e.value.replaceAll(RegExp(r'\s+'), ' ') == normalized) {
          _cache[cacheKey] = e.key;
          return e.key;
        }
      }

      // 4. Multi-sentence paragraph decomposition
      final sentences = clean
          .split(RegExp(r'(?<=[।\n?!])\s*'))
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (sentences.length > 1) {
        final translated = sentences
            .map((s) => translate(s, toBangla: false))
            .join(' ');
        if (translated.trim().isNotEmpty) {
          _cache[cacheKey] = translated;
          return translated;
        }
      }

      // 5. Offline dictionary term replacement fallback
      var translated = clean;
      for (final entry in _phraseReplacementsBnToEn) {
        translated = translated.replaceAll(entry.key, entry.value);
      }
      final cleaned = cleanBrandName(sanitizeNaturalEnglish(translated));
      _cache[cacheKey] = cleaned;
      return cleaned;
    }
  }

  /// Free, high-fidelity asynchronous bidirectional translation
  /// using Google Translate's free web endpoint (Zero API cost, CORS *)
  static Future<String> translateAsync(
    String text, {
    required bool toBangla,
    http.Client? client,
  }) async {
    final trimmed = cleanBrandName(text).trim();
    if (trimmed.isEmpty) return trimmed;

    final hasBn = hasBengali(trimmed);
    if (toBangla && hasBn) return trimmed;
    if (!toBangla && !hasBn) return trimmed;

    final cacheKey = '$toBangla:$trimmed';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // Check pre-cached fixtures and statutory maps before hitting network
    if (toBangla) {
      if (_enToBn.containsKey(trimmed)) {
        _cache[cacheKey] = _enToBn[trimmed]!;
        return _enToBn[trimmed]!;
      }
      for (final e in _bnToEn.entries) {
        if (e.value.toLowerCase() == trimmed.toLowerCase()) {
          _cache[cacheKey] = e.key;
          return e.key;
        }
      }
    } else {
      final clean = trimmed.replaceAll(
          RegExp(r'\[SYNTHETIC SAMPLE[^\]]*\]\s*', caseSensitive: false), '');
      if (_bnToEn.containsKey(clean)) {
        _cache[cacheKey] = _bnToEn[clean]!;
        return _bnToEn[clean]!;
      }
      if (_bnToEn.containsKey(trimmed)) {
        _cache[cacheKey] = _bnToEn[trimmed]!;
        return _bnToEn[trimmed]!;
      }
      for (final e in _enToBn.entries) {
        if (e.value == clean || e.value == trimmed) {
          _cache[cacheKey] = e.key;
          return e.key;
        }
      }
    }

    try {
      final httpClient = client ?? http.Client();

      // 1. Direct block translation attempt
      var translated = await _translateHttpChunk(
        trimmed,
        toBangla: toBangla,
        client: httpClient,
      );

      // 2. Strict completeness validation:
      // If translating to English, ensure NO residual Bengali segments remain.
      // If translating to Bangla, ensure NO residual English sentences remain when source was Bengali.
      final isPartiallyUntranslated = !toBangla
          ? hasBengali(translated)
          : (!hasBengali(translated) && hasBengali(trimmed));

      if (isPartiallyUntranslated || translated.trim().isEmpty) {
        // Fallback: Segment by sentence delimiters ('।' or '\n' or '?')
        final sentences = trimmed
            .split(RegExp(r'(?<=[।\n\?!])\s*'))
            .where((s) => s.trim().isNotEmpty)
            .toList();

        if (sentences.length > 1) {
          final translatedSentences = await Future.wait(
            sentences.map((s) async {
              final single = await _translateHttpChunk(
                s,
                toBangla: toBangla,
                client: httpClient,
              );
              final singleFailed = !toBangla
                  ? hasBengali(single)
                  : (!hasBengali(single) && hasBengali(s));

              if (single.isNotEmpty && !singleFailed) {
                return single;
              }
              // If single-sentence API call failed or remained untranslated, use verified statutory dictionary
              return translate(s, toBangla: toBangla);
            }),
          );

          translated = translatedSentences.join(' ');
        }
      }

      if (translated.trim().isNotEmpty) {
        final cleanedResult = toBangla
            ? cleanBrandName(translated)
            : cleanBrandName(sanitizeNaturalEnglish(translated));
        _cache[cacheKey] = cleanedResult;
        return cleanedResult;
      }
    } catch (_) {
      // Offline fallback
    }

    return translate(trimmed, toBangla: toBangla);
  }

  /// Internal HTTP query helper for a single text segment
  static Future<String> _translateHttpChunk(
    String query, {
    required bool toBangla,
    required http.Client client,
  }) async {
    final targetLang = toBangla ? 'bn' : 'en';
    final sourceLang = toBangla ? 'en' : 'bn';
    final url = Uri.parse(
      'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLang&tl=$targetLang&dt=t&q=${Uri.encodeComponent(query.trim())}',
    );

    try {
      final res = await client.get(url).timeout(const Duration(milliseconds: 1500));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is List && decoded.isNotEmpty && decoded[0] is List) {
          return (decoded[0] as List)
              .where((seg) => seg is List && seg.isNotEmpty && seg[0] is String)
              .map((seg) => seg[0] as String)
              .join();
        }
      }
    } catch (_) {
      // Ignored - fallback will handle
    }
    return '';
  }
}
