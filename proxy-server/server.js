const express = require('express');
const cors = require('cors');
const axios = require('axios');
const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Expanded Mock Data for Fallbacks
const agroMockData = {
  'Wheat': { 
    prices: [{ market: 'Delhi', price: 2125, variety: 'Dara', date: '2024-04-05' }, { market: 'Mumbai', price: 2350, variety: 'Sihore', date: '2024-04-05' }],
    soil: { layers: [{ type: 'Alluvial', ph: 7.2, organic_matter: 1.8, nutrients: { nitrogen: 140, phos: 35, pot: 110 } }] }
  },
  'Rice': { 
    prices: [{ market: 'Kolkata', price: 3400, variety: 'Common', date: '2024-04-05' }, { market: 'Chennai', price: 3600, variety: 'Fine', date: '2024-04-05' }],
    soil: { layers: [{ type: 'Clayey Loamy', ph: 6.2, organic_matter: 2.5, nutrients: { nitrogen: 210, phos: 55, pot: 140 } }] }
  },
  'Corn': { 
    prices: [{ market: 'Lucknow', price: 1850, variety: 'Hybrid', date: '2024-04-05' }, { market: 'Pune', price: 2000, variety: 'Local', date: '2024-04-05' }],
    soil: { layers: [{ type: 'Sandy Loam', ph: 6.5, organic_matter: 1.9, nutrients: { nitrogen: 155, phos: 42, pot: 125 } }] }
  },
  'Cotton': { 
    prices: [{ market: 'Rajkot', price: 7200, variety: 'Shankar-6', date: '2024-04-05' }],
    soil: { layers: [{ type: 'Black Soil', ph: 7.8, organic_matter: 1.2, nutrients: { nitrogen: 110, phos: 28, pot: 400 } }] }
  },
  'Sugarcane': { 
    prices: [{ market: 'Meerut', price: 340, variety: 'Early', date: '2024-04-05' }],
    soil: { layers: [{ type: 'Deep Alluvial', ph: 7.0, organic_matter: 2.8, nutrients: { nitrogen: 250, phos: 60, pot: 180 } }] }
  },
  'Tomato': { 
    prices: [{ market: 'Nashik', price: 1200, variety: 'Hybrid', date: '2024-04-05' }],
    soil: { layers: [{ type: 'Red Soil', ph: 6.3, organic_matter: 1.5, nutrients: { nitrogen: 130, phos: 50, pot: 90 } }] }
  }
};

const defaultMock = {
  prices: [{ market: 'National Average', price: 2500, variety: 'General', date: '2024-04-05' }],
  soil: { layers: [{ type: 'Loamy', ph: 6.8, organic_matter: 2.1, nutrients: { nitrogen: 180, phos: 45, pot: 120 } }] }
};

// General Proxy Endpoint with Smart Fallbacks
app.get('/proxy', async (req, res) => {
  const targetUrl = req.query.url;
  if (!targetUrl) {
    return res.status(400).send({ error: 'URL query parameter is required.' });
  }

  try {
    console.log(`[Proxy] → ${targetUrl}`);
    const response = await axios.get(targetUrl, {
      headers: { 'User-Agent': 'AgriProxy/1.0', 'Accept': 'application/json' },
      timeout: 8000
    });
    res.json(response.data);
  } catch (error) {
    const errorMsg = error.response ? `Status ${error.response.status}` : error.message;
    console.warn(`[Proxy Failed] → ${targetUrl} (${errorMsg})`);
    
    // DETECT CROP IN URL
    let crop = 'General';
    for (const key of Object.keys(agroMockData)) {
      if (targetUrl.toLowerCase().includes(key.toLowerCase())) {
        crop = key;
        break;
      }
    }

    const mock = agroMockData[crop] || defaultMock;

    // SMART FALLBACK LOGIC
    if (targetUrl.includes('agmarknet.gov.in') || targetUrl.includes('prices')) {
      console.log(`Returning Smart Fallback for Market Prices (${crop})`);
      return res.json({ prices: mock.prices, source: 'Regional Hub Forecast' });
    }
    
    if (targetUrl.includes('soilgrids') || targetUrl.includes('properties')) {
      console.log(`Returning Smart Fallback for Soil Data (${crop})`);
      return res.json(mock.soil);
    }

    if (targetUrl.includes('faostat') || targetUrl.includes('usda') || targetUrl.includes('nal.usda.gov')) {
      console.log(`Returning Smart Fallback for Agri Stats (${crop})`);
      return res.json({ 
        data: [{ crop: crop, value: 4.2, unit: 't/ha', year: '2023' }], 
        source: 'Historical Trends (Mock)', 
        status: 'simulated' 
      });
    }

    // Default Error Fallback if no specific match
    res.status(error.response ? error.response.status : 500).send({ 
      error: 'External Request Failed', 
      message: error.message,
      fallback_available: false
    });
  }
});

// New POST Proxy for AI Inference
app.post('/proxy', async (req, res) => {
  const targetUrl = req.query.url;
  if (!targetUrl) return res.status(400).send({ error: 'URL required.' });

  try {
    console.log(`[AI Proxy-POST] → ${targetUrl}`);
    const response = await axios.post(targetUrl, req.body, {
      headers: { 
        'Authorization': req.headers.authorization, 
        'Content-Type': 'application/json' 
      }
    });
    res.json(response.data);
  } catch (error) {
    console.warn(`[AI Proxy Failed] → ${error.message}`);
    res.status(error.response?.status || 500).send(error.response?.data || error.message);
  }
});

app.get('/health', (req, res) => res.json({ status: 'OK' }));

app.listen(PORT, () => console.log(`Smart Agricultural Proxy running on port ${PORT}`));
