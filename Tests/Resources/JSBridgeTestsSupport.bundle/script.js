function Tester() {
    this.title = document.title;
}

/* TYPE SYSTEM */

Tester.prototype.refresh = function() {
    return true;
}

Tester.prototype.clearQueue = function() {
    return;
}

/* VALUE DECODING */

Tester.prototype.testString = function() {
    return "Hello, world!";
}

Tester.prototype.testNumber = function() {
    return 42;
}

Tester.prototype.testBool = function() {
    return true;
}

Tester.prototype.testValidMockTargetType = function() {
    return "app";
}

Tester.prototype.invalidTestMockTargetRawType = function() {
    return 100;
}

Tester.prototype.testTarget = function() {
    return {
        name: "Client",
        targetType: "app",
        categories: [
            "News", "Entertainment"
        ]
    };
}

Tester.prototype.invalidTestTarget = function() {
    return false;
}


Tester.prototype.invalidTestTargetPrototype = function() {
    return {
        name: "Client",
        targetType: "app",
        categories: null
    };
}

Tester.prototype.testPrimitivesArray = function() {
    return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
}

Tester.prototype.testInvalidPrimitivesArray = function() {
    return "trolld";
}

Tester.prototype.testInvalidMixedPrimitivesArray = function() {
    return [1, "un", 2, "deux", 3, "trois"];
}

Tester.prototype.testMockTargetTypes = function() {
    return ["app", "executable"];
}

Tester.prototype.testInvalidMockTargetTypes = function() {
    return false;
}

Tester.prototype.testInvalidRawMockTargetTypes = function() {
    return [1, 2, 3];
}

Tester.prototype.testUnknownRawMockTargetTypes = function() {
    return ["app", "kext"];
}

Tester.prototype.testObjects = function() {
    return [
        {
            "name": "Client",
            "targetType": "app",
            "categories": ["News", "Entertainment"]
        },
        {
            "name": "ClientTests",
            "targetType": "unitTest",
            "categories": ["DT", "Tests"]
        }
    ];
}

Tester.prototype.testInvalidObjects = function() {
    return false;
}

Tester.prototype.textMixedObjects = function() {
    return [
        {
            "name": "Client",
            "targetType": "app",
            "categories": ["News"]
        },
        false
    ];
}

Tester.prototype.textDifferentObjectPrototypes = function() {
    return [
        {
            "name": "Client",
            "targetType": "app",
            "categories": ["News"]
        },
        {
            "name": "SpaceTravelKit",
            "targetType": undefined
        }
    ];
}


/* GLOBALS */
var tester = new Tester();
