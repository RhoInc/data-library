import makeMainDataList from './makeMainDataList';
import makeSubDataList from './makeSubDataList';

if (typeof context !== 'undefined' && context == 'main') {
    makeMainDataList();
} else {
    makeSubDataList();
}
