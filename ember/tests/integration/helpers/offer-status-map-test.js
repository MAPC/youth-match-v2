
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('offer-status-map', 'helper:offer-status-map', {
  integration: true
});

// Replace this with your real tests.
test('it renders', function(assert) {
  this.set('inputValue', '1234');

  this.render(hbs`{{offer-status-map inputValue}}`);

  assert.equal(this.$().text().trim(), '1234');
});

