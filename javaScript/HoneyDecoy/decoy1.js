// Self-executing anonymous function to create a private scope
// This helps to avoid polluting the global namespace.
(function() {

    // --- Core Configuration (Highly Obfuscated and Placeholder for Encryption) ---
    // IMPORTANT: In a real-world scenario, these values, especially _secretKey and _logEndpoint,
    // MUST NOT be hardcoded in the client-side JavaScript. They should be
    // securely fetched, dynamically generated, or managed server-side.
    // The XOR "encryption" here is for demonstration only and is cryptographically WEAK.
    const _configData = {
        _logEndpoint: '/api/honeypot-log', // Where to send captured data
        _detectionThreshold: 5,           // How many suspicious actions before logging
        _secretKey: 'a_very_secret_key_1234567890123456', // Placeholder: Use a stronger, dynamic key in production.
                                                      // For demonstration, length increased for potential AES
                                                      // if Web Crypto API were used (e.g., 16, 24, or 32 chars).
        _trapFields: [                    // Names of the honeypot input fields
            'username_trap',
            'email_trap',
            'password_trap',
            'phone_number_trap' // Added another trap field for variety
        ],
        _camouflageStyles: {             // CSS to hide the fields
            'position': 'absolute',
            'left': '-9999px',
            'opacity': '0',
            'pointer-events': 'none', // Prevents mouse events
            'height': '1px',
            'width': '1px',
            'overflow': 'hidden',     // Ensures content doesn't bleed
            'border': '0',            // Remove borders
            'padding': '0',           // Remove padding
            'margin': '0'             // Remove margin
        },
        _honeypotVersion: '1.2.0' // Added for tracking and server-side analysis
    };

    // --- Utility Functions (Private and Placeholder for Secure Encryption) ---

    // WARNING: This XOR function is for DEMONSTRATION ONLY. It provides NO real security.
    // For production, you MUST use the Web Crypto API for secure encryption (e.g., AES-GCM).
    // Example (conceptual, as Web Crypto API functions are global):
    /*
    async function _encryptData(data, key) {
        const encoder = new TextEncoder();
        const dataBuffer = encoder.encode(data);
        const iv = window.crypto.getRandomValues(new Uint8Array(12)); // IV for AES-GCM
        const alg = { name: 'AES-GCM', iv: iv };
        const cryptoKey = await window.crypto.subtle.importKey(
            'raw', encoder.encode(key), alg, false, ['encrypt']
        );
        const encrypted = await window.crypto.subtle.encrypt(alg, cryptoKey, dataBuffer);
        return { encrypted: btoa(String.fromCharCode(...new Uint8Array(encrypted))), iv: btoa(String.fromCharCode(...iv)) };
    }
    */
    function _xorEncryptDecrypt(str, key) {
        let output = '';
        for (let i = 0; i < str.length; i++) {
            let charCode = str.charCodeAt(i) ^ key.charCodeAt(i % key.length);
            output += String.fromCharCode(charCode);
        }
        return output;
    }

    // Function to safely send data (uses XMLHttpRequest, which is a global API)
    // In a real app, this would be highly secured with CORS, CSRF tokens, etc.
    function _sendData(data) {
        // Obfuscate the endpoint path or derive it securely
        const encryptedEndpoint = _xorEncryptDecrypt(_configData._logEndpoint, _configData._secretKey);
        const actualEndpoint = _xorEncryptDecrypt(encryptedEndpoint, _configData._secretKey); // Decrypt

        try {
            const xhr = new XMLHttpRequest();
            xhr.open('POST', actualEndpoint, true);
            xhr.setRequestHeader('Content-Type', 'application/json');
            // Add custom headers for server-side verification/security
            // Encrypt the token to make it harder to spoof
            xhr.setRequestHeader('X-Honeypot-Token', _xorEncryptDecrypt(JSON.stringify({ts: Date.now(), v: _configData._honeypotVersion}), _configData._secretKey));
            xhr.timeout = 5000; // 5 seconds timeout for sending data

            xhr.onload = function() {
                // Minimal feedback; do NOT log sensitive info in production.
                // if (xhr.status >= 200 && xhr.status < 300) { /* Success */ }
                // else { /* Error */ }
            };
            xhr.onerror = function() {
                // Network error, do nothing or log silently
            };
            xhr.ontimeout = function() {
                // Request timed out, do nothing or log silently
            };

            xhr.send(JSON.stringify(data));
        } catch (e) {
            // Error sending, do nothing or log silently
        }
    }

    // Anti-tampering and integrity check function
    // This is highly simplified. A real one would involve complex hashing/checksums
    // and potentially remote verification or MutationObserver.
    function _integrityCheck() {
        try {
            const trapElements = _configData._trapFields.map(name =>
                document.querySelector(`input[name="${name}"]`)
            ).filter(Boolean); // Filter out null/undefined results

            // If any trap element is missing, it's a strong sign of tampering
            if (trapElements.length !== _configData._trapFields.length) {
                return false; // Elements removed or not found
            }

            for (const el of trapElements) {
                // Check if styles have been tampered with
                let isHidden = true;
                for (const prop in _configData._camouflageStyles) {
                    // Using getComputedStyle for more robust check against overridden styles
                    const computedStyle = window.getComputedStyle(el); // window.getComputedStyle is global
                    if (computedStyle[prop] !== _configData._camouflageStyles[prop]) {
                        isHidden = false;
                        break;
                    }
                }
                // Check if element is visually rendered (offsetParent is null if hidden)
                // Also check if type was changed, which is an easy bypass.
                if (!isHidden || el.offsetParent !== null || el.type !== 'text') {
                    return false; // Tampering detected
                }
            }
        } catch (e) {
            // Any error during check means potential tampering or an unstable environment
            return false;
        }
        return true;
    }

    // --- Honeypot Logic (Private and Event-Driven) ---
    let _suspicionScore = 0;
    let _honeypotData = {};

    function _detectBotActivity(event) {
        let increment = 0;
        const target = event.target;

        // Check for rapid form submission
        if (event.type === 'submit') {
            const formElements = Array.from(target.elements);
            let honeypotFieldFilledCount = 0;
            _honeypotData.filledFields = _honeypotData.filledFields || []; // Ensure it's an array

            _configData._trapFields.forEach(fieldName => {
                const field = formElements.find(el => el.name === fieldName);
                if (field && field.value && field.value.length > 0) { // Check for non-empty string
                    honeypotFieldFilledCount++;
                    _honeypotData.filledFields.push({ name: fieldName, value: field.value });
                }
            });

            if (honeypotFieldFilledCount > 0) {
                increment += (2 * honeypotFieldFilledCount); // Higher score based on number of filled fields
            }

            // Check if submission happened too quickly (e.g., less than 2 seconds)
            const submitTime = Date.now();
            if (_honeypotData.formLoadTime && (submitTime - _honeypotData.formLoadTime) < 2000) {
                increment += 2; // Very fast submission
                _honeypotData.fastSubmit = true;
            }

            // Add a check for hidden field interaction count vs. total fields
            _honeypotData.totalFormFields = formElements.length;
        }

        // Check for focus on hidden fields
        // Using event delegation: ensures listener is robust even if elements are swapped
        if (event.type === 'focusin' && _configData._trapFields.includes(target.name)) {
            increment += 1; // Focusing on a hidden trap field
            _honeypotData.focusedHiddenField = target.name;
        }

        // Check for paste events into hidden fields (indicates automation)
        // Using event delegation
        if (event.type === 'paste' && _configData._trapFields.includes(target.name)) {
            increment += 2; // Pasting into a hidden trap field
            _honeypotData.pastedIntoHiddenField = target.name;
        }

        // Mouse movement patterns (or lack thereof) - conceptual
        // This is highly complex. For real-world, track mouse coordinates and timestamps.
        // Look for: lack of movement, perfectly straight lines, instantaneous jumps.
        /*
        if (event.type === 'mousemove') {
            // Logic to track mouse positions over time
            _honeypotData.mouse_positions = _honeypotData.mouse_positions || [];
            _honeypotData.mouse_positions.push({ x: event.clientX, y: event.clientY, ts: Date.now() });
            if (_honeypotData.mouse_positions.length > 50) _honeypotData.mouse_positions.shift(); // Keep buffer limited
            // Add more sophisticated analysis here (e.g., calculate path smoothness)
        }
        */

        _suspicionScore += increment;

        // Trigger log only if suspicion threshold is met AND integrity check passes
        if (_suspicionScore >= _configData._detectionThreshold && _integrityCheck()) {
            _honeypotData.score = _suspicionScore;
            _honeypotData.userAgent = navigator.userAgent;
            _honeypotData.ipAddress = ''; // Captured server-side
            _honeypotData.timestamp = Date.now();
            _honeypotData.referrer = document.referrer;
            _honeypotData.screenResolution = `${window.screen.width}x${window.screen.height}`; // Global
            _honeypotData.language = navigator.language; // Global

            // Send encrypted data
            const encryptedData = _xorEncryptDecrypt(JSON.stringify(_honeypotData), _configData._secretKey);
            _sendData({ data: encryptedData });

            // Reset for subsequent detections. Use a short delay before resetting to
            // prevent rapid re-triggering while a bot is active.
            setTimeout(() => {
                _suspicionScore = 0;
                _honeypotData = {};
            }, 1000); // Wait 1 second before allowing new detections
        }
    }

    // --- Honeypot Initialization ---
    function _initializeHoneypot() {
        const forms = document.querySelectorAll('form');

        forms.forEach(form => {
            _configData._trapFields.forEach(fieldName => {
                const input = document.createElement('input');
                input.type = 'text'; // Can be any type, but text is common for bots to target
                input.name = fieldName;
                input.tabIndex = -1; // Make it untabbable
                input.setAttribute('aria-hidden', 'true'); // For accessibility tools
                input.setAttribute('autocomplete', 'off'); // Prevent legitimate autofill
                input.setAttribute('spellcheck', 'false'); // No spellcheck for bots

                // Apply camouflage styles
                for (const prop in _configData._camouflageStyles) {
                    input.style[prop] = _configData._camouflageStyles[prop];
                }

                // Append as the first child to make it harder to spot in DOM inspection,
                // and for some CSS nth-child selectors.
                if (form.firstChild) {
                    form.insertBefore(input, form.firstChild);
                } else {
                    form.appendChild(input);
                }
            });

            // Use event delegation for focusin and paste events on the form itself.
            // This is more robust against DOM manipulation than adding listeners to individual elements.
            form.addEventListener('focusin', _detectBotActivity); // focusin bubbles, focus does not
            form.addEventListener('paste', _detectBotActivity);
            form.addEventListener('submit', _detectBotActivity);

            // Record form load time for submission speed detection
            _honeypotData.formLoadTime = Date.now();
        });

        // Add a global mousemove listener (if more advanced bot detection is needed)
        // document.addEventListener('mousemove', _detectBotActivity);
        // Add a global scroll listener (for detection of non-human like scrolling)
        // document.addEventListener('scroll', _detectBotActivity);
    }

    // --- Obfuscated Entry Point ---
    const _readyCheck = function() {
        // document.readyState is a global property
        if (document.readyState === 'loading') {
            // Use 'DOMContentLoaded' for robust execution after DOM is parsed but before external resources
            window.addEventListener('DOMContentLoaded', _initializeHoneypot);
        } else {
            // DOM is already ready
            _initializeHoneypot();
        }
    };

    // Call the ready check function to start the process
    _readyCheck();

    // Prevent re-initialization or external access to internal functions
    // by making sure nothing from this scope is exposed globally.
})();
