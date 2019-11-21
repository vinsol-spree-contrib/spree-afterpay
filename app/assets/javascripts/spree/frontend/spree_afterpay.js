//= require spree/frontend
function SpreeAfterpaySource() {
}

SpreeAfterpaySource.prototype.isButtonHidden = function() {
  var paymentMethod = this.checkedPaymentMethod();
  return (!$('#use_existing_card_yes:checked').length && SpreeAfterpaySource.paymentMethodID && paymentMethod.val() == SpreeAfterpaySource.paymentMethodID);
};

SpreeAfterpaySource.prototype.checkedPaymentMethod = function() {
  return $('div[data-hook="checkout_payment_step"] input[type="radio"][name="order[payments_attributes][][payment_method_id]"]:checked');
};

SpreeAfterpaySource.prototype.hideSaveAndContinue = function() {
  $("#checkout_form_payment [data-hook=buttons]").hide();
};

SpreeAfterpaySource.prototype.showSaveAndContinue = function() {
  $("#checkout_form_payment [data-hook=buttons]").show();
};

SpreeAfterpaySource.prototype.updateSaveAndContinueVisibility = function() {
  if (this.isButtonHidden()) {
    this.hideSaveAndContinue();
  } else {
    this.showSaveAndContinue();
  }
};

SpreeAfterpaySource.prototype.init = function() {
  var _this = this;

  this.updateSaveAndContinueVisibility();
  $('div[data-hook="checkout_payment_step"] input[type="radio"]').click(function (e) {
    _this.updateSaveAndContinueVisibility();
  });
};

$(function() {
  var spree_afterpay_source = new SpreeAfterpaySource();
  spree_afterpay_source.init();
});
