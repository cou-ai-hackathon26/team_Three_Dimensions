import 'package:flutter_test/flutter_test.dart';
import 'package:mylaws/core/services/legal_translation_service.dart';

void main() {
  group('LegalTranslationService Natural Bangla & Tone Tests', () {
    test('Cleans machine-translated lost wallet text into natural respectful Bangla', () {
      const clumsyInput =
          'আপনার মানিব্যাগ হারানো খুব চাপ এবং বিরক্তিকর, বিশেষ করে আপনার টাকা, NID, ব্যাঙ্ক কার্ড ভিতরে আছে। অনুগ্রহ করে চিন্তা করবেন না, বাংলাদেশে আপনার স্পষ্ট আইনি সুরক্ষা আছে।\n\n'
          'আইনের অধীনে, আপনার মানিব্যাগ চুরি করা চুরির অপরাধ — ধারা 378-এ সংজ্ঞায়িত এবং দণ্ডবিধি 1860-এর ধারা 379-এর অধীনে শাস্তিযোগ্য 3 বছর পর্যন্ত কারাদণ্ড এবং জরিমানা। একজন ভিকটিম হিসেবে পুলিশের কাছ থেকে সাহায্য পাওয়ার অধিকার আপনার আছে।\n\n'
          'দ্রুত একটি জিডি/এফআইআর দায়ের করা শুধুমাত্র এটি পুনরুদ্ধার করতে এবং চোরকে ধরতে সাহায্য করে না, তবে এটি আইনত আপনাকে রক্ষা করে যদি আপনার NID, কার্ড বা নথি অন্য কেউ অপব্যবহার করে থাকে।';

      final sanitized = LegalTranslationService.cleanBrandName(clumsyInput);

      // Verify elimination of clumsy/robotic terms
      expect(sanitized.contains('বিরক্তিকর'), isFalse);
      expect(sanitized.contains('ভিকটিম'), isFalse);
      expect(sanitized.contains('চুরি করা চুরির অপরাধ'), isFalse);
      expect(sanitized.contains('শুধুমাত্র এটি পুনরুদ্ধার করতে'), isFalse);

      // Verify presence of natural phrasing
      expect(sanitized.contains('মানিব্যাগ হারানো সত্যিই দুশ্চিন্তার বিষয়'), isTrue);
      expect(sanitized.contains('টাকা, NID ও ব্যাংক কার্ড থাকলে'), isTrue);
      expect(sanitized.contains('এ ধরনের পরিস্থিতিতে আপনার আইনি সহায়তা পাওয়ার অধিকার রয়েছে'), isTrue);
      expect(sanitized.contains('যদি কেউ আপনার অনুমতি ছাড়া অসৎ উদ্দেশ্যে মানিব্যাগ নিয়ে যায়'), isTrue);
      expect(sanitized.contains('বাংলাদেশের দণ্ডবিধি, 1860-এর 378 ধারায় চুরির সংজ্ঞা দেওয়া হয়েছে এবং 379 ধারায় এর শাস্তি'), isTrue);
      expect(sanitized.contains('ভুক্তভোগী হিসেবে'), isTrue);
      expect(sanitized.contains('থানায় যোগাযোগ করে অভিযোগ জানান। আর হারিয়ে গিয়ে থাকলে একটি জিডি করুন'), isTrue);
    });

    test('Translates canonical English wallet explanation directly to desired Bangla', () {
      const englishText =
          'Losing your wallet is stressful and frustrating, especially with your money, NID, bank cards inside. Please don\'t worry, you have clear legal protection in Bangladesh.';

      final bangla = LegalTranslationService.translate(englishText, toBangla: true);
      expect(bangla, contains('মানিব্যাগ হারানো সত্যিই দুশ্চিন্তার বিষয়'));
      expect(bangla, contains('টাকা, NID ও ব্যাংক কার্ড থাকলে'));
      expect(bangla, contains('এ ধরনের পরিস্থিতিতে আপনার আইনি সহায়তা পাওয়ার অধিকার রয়েছে'));
    });

    test('Bidirectional translation preserves polite tone without loss', () {
      const bnText =
          'মানিব্যাগ হারানো সত্যিই দুশ্চিন্তার বিষয়, বিশেষ করে এর মধ্যে টাকা, NID ও ব্যাংক কার্ড থাকলে। তবে চিন্তা করবেন না, এ ধরনের পরিস্থিতিতে আপনার আইনি সহায়তা পাওয়ার অধিকার রয়েছে।';

      final en = LegalTranslationService.translate(bnText, toBangla: false);
      expect(en, contains('wallet'));
      expect(en, contains('stressful'));

      final backToBn = LegalTranslationService.translate(en, toBangla: true);
      expect(backToBn, contains('মানিব্যাগ হারানো সত্যিই দুশ্চিন্তার বিষয়'));
    });
  });
}
