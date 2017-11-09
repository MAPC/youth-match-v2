import Ember from 'ember';
import { computed, action } from 'ember-decorators/object';
import PaginatedController from '../../PaginatedController';

export default PaginatedController.extend({

  session: Ember.inject.service(),
  ajax: Ember.inject.service(),

  loading: true,
  threshold: 1,

  resettingPassword: false,

  searchQuery: '',


  @computed('model.[]', 'searchQuery')
  sortedModel(model, query) {
    if (model.get('length') > this.get('threshold')) {
      this.set('loading', false);
    }

    let results = model;

    if (query.length > 1) {
      this.resetPage();
      query = query.toLowerCase();

      results = results.filter(x => x.get('email').toLowerCase().startsWith(query));
    }

    return results.sortBy('email');
  },


  @computed('sortedModel.[]')
  modelLength(sortedModel) { return sortedModel.get('length'); },


  @computed('sortedModel', 'min', 'max')
  filteredModel(sortedModel, min, max) {
    return sortedModel.slice(min, max);
  },


  @action 
  regeneratePassword(user) {
    if (!this.get('resettingPassword')) {
      this.set('resettingPassword', true);

      const user_id = user.get('id');

      this.store.createRecord('passwordReset', { user_id })
      .save()
      .catch(() => {
        const userEmail = user.get('email');
        //this.set('errorMessage', `Could not reset credentials for ${userEmail}.`);
      })
      .finally(() => {
        this.set('resettingPassword', false);
      });
    }
  },



});
