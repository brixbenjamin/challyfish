import 'package:feral/src/data/remote/revenuecat_gateway.dart';
import 'package:feral/src/domain/purchase.dart';
import 'package:purchases_flutter/purchases_flutter.dart'
    show PurchasesErrorCode;
import 'package:test/test.dart';

void main() {
  const owned = {'com.example.feral.pack.edge'};

  test('a cancelled purchase is a decision, not an error', () {
    expect(
      outcomeForErrorCode(
        PurchasesErrorCode.purchaseCancelledError,
        owned: const {},
      ),
      isA<PurchaseCancelled>(),
    );
  });

  test('a pending payment is pending, not failed', () {
    // Parental approval, a bank step, a slow store. The purchase is real and
    // resolves through the webhook; telling the user it failed would be a lie
    // they act on by buying again.
    expect(
      outcomeForErrorCode(
        PurchasesErrorCode.paymentPendingError,
        owned: const {},
      ),
      isA<PurchasePending>(),
    );
  });

  test('already-owned reports what is owned so a restore can follow', () {
    final outcome = outcomeForErrorCode(
      PurchasesErrorCode.productAlreadyPurchasedError,
      owned: owned,
    );

    expect(outcome, isA<PurchaseAlreadyOwned>());
    expect((outcome as PurchaseAlreadyOwned).ownedProductIds, owned);
  });

  test('a store problem is a failure with plain words', () {
    final outcome = outcomeForErrorCode(
      PurchasesErrorCode.networkError,
      owned: const {},
    );

    expect(outcome, isA<PurchaseFailed>());
    final message = (outcome as PurchaseFailed).message;
    expect(message, isNotEmpty);
    expect(message.toLowerCase(), isNot(contains('error code')));
    expect(message, isNot(contains('PurchasesErrorCode')));
  });

  test('purchases being disabled on the device says so specifically', () {
    final outcome = outcomeForErrorCode(
      PurchasesErrorCode.purchaseNotAllowedError,
      owned: const {},
    );
    expect(outcome, isA<PurchaseFailed>());
    expect(
      (outcome as PurchaseFailed).message.toLowerCase(),
      contains('device'),
    );
  });

  test('an unrecognised code still produces a usable message', () {
    final outcome = outcomeForErrorCode(
      PurchasesErrorCode.unknownError,
      owned: const {},
    );
    expect(outcome, isA<PurchaseFailed>());
    expect((outcome as PurchaseFailed).message, isNotEmpty);
  });
}
