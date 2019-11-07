//= require spree/frontend
function SpreeAfterpaySource(options) {
}

SpreeAfterpaySource.prototype.isButtonHidden = function() {
  paymentMethod = this.checkedPaymentMethod();
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
    $(this).trigger('hideSaveAndContinue')
  } else {
    $(this).trigger('showSaveAndContinue')
  }
};


SpreeAfterpaySource.prototype.init = function() {
  var _this = this;

  this.updateSaveAndContinueVisibility();
  paymentMethods = $('div[data-hook="checkout_payment_step"] input[type="radio"]').click(function (e) {
    _this.updateSaveAndContinueVisibility();
  });
};

$(function() {
  var options = {};

  spree_afterpay_source = new SpreeAfterpaySource(options);
  spree_afterpay_source.init();
});
