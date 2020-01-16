//= require spree/frontend
function SpreeAfterpaySource() {
}

SpreeAfterpaySource.prototype._isButtonHidden = function() {
  var paymentMethod = this.checkedPaymentMethod();
  return (!$('#use_existing_card_yes:checked').length && SpreeAfterpaySource.paymentMethodID && paymentMethod.val() == SpreeAfterpaySource.paymentMethodID);
};

SpreeAfterpaySource.prototype._checkedPaymentMethod = function() {
  return $('div[data-hook="checkout_payment_step"] input[type="radio"][name="order[payments_attributes][][payment_method_id]"]:checked');
};

SpreeAfterpaySource.prototype._hideSaveAndContinue = function() {
  $("#checkout_form_payment [data-hook=buttons]").hide();
};

SpreeAfterpaySource.prototype._showSaveAndContinue = function() {
  $("#checkout_form_payment [data-hook=buttons]").show();
};

SpreeAfterpaySource.prototype._updateSaveAndContinueVisibility = function() {
  if (this._isButtonHidden()) {
    this._hideSaveAndContinue();
  } else {
    this._showSaveAndContinue();
  }
};

SpreeAfterpaySource.prototype.init = function() {
  var _this = this;

  this._updateSaveAndContinueVisibility();
  $('div[data-hook="checkout_payment_step"] input[type="radio"]').click(function (e) {
    _this._updateSaveAndContinueVisibility();
  });
};

$(function() {
  var spree_afterpay_source = new SpreeAfterpaySource();
  spree_afterpay_source.init();
});
