import Ember from 'ember';
import { action } from 'ember-decorators/object';


export default Ember.Component.extend({

  @action
  downloadData() {
    const fileName = this.get('fileName');
    let data = this.get('data');

    if (data.content) {
      data = data.content;
    }

    const csvHeader = "data:text/csv;charset=utf-8,";

    const documentHeader = Object.keys(data[0]);
    const documentRows = data.map(row => Object.keys(row).map(key => row[key]))
                             .map(row => row.map(value => Array.isArray(value) ? value.join(';') : value))
                             .map(row => row.map(value => (typeof value === 'string') ? value.split(',').join(';') : value ));

    const documentStructure = [[documentHeader], documentRows].reduce((a,b) => a.concat(b));
    const documentBody = documentStructure.reduce((a,b) => `${a}\n${b}`);

    const csvFile = csvHeader + documentBody;
    const encoded = encodeURI(csvFile);

    const link = document.createElement('a');
    link.setAttribute('href', encoded);
    link.setAttribute('download', `${fileName}.csv`);

    document.body.appendChild(link);
    link.click();
  },

});
