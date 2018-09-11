import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter } from 'react-router-dom'

import './index.css';
import SendleApiApp from './App';
// import registerServiceWorker from './registerServiceWorker';

ReactDOM.render(<BrowserRouter><SendleApiApp /></BrowserRouter>, document.getElementById('root'))

// registerServiceWorker();
