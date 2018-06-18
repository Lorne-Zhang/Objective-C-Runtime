//
//  ViewController.m
//  RuntimeExamples
//
//  Created by flying on 2018/6/18.
//  Copyright © 2018 flying. All rights reserved.
//

#import "ViewController.h"
#import "OtherObject.h"
#import "Warrior.h"
#import <objc/runtime.h>

enum FooManChu { FOO, MAN, CHU };
struct YorkshireTeaStruct { int pot; char lady;};
typedef  struct YorkshireTeaStruct YorkshireTeaStructType;
union MoneyUnion { float alone; double donw; };

@interface ViewController ()
@property float alone;
@property char charDefualt;
@property enum FooManChu enumDefault;
@property signed signedDefault;
@property struct YorkshireTeaStruct structDefault;
@property YorkshireTeaStructType typedefDefault;
@property union MoneyUnion unionDefault;
@property int (*functionPointerDefault)(char *); // function pointer
@property id idDefault;
@property int *intPointer;
@property int intSynthEquals;
@property( getter=intGetFoo, setter=intSetFoo:) int
intSetterGetter;
@property(getter= isIntReadonlyGetter, readonly) int
intReadonlyGetter;
@property (readwrite) int intReadwrite;
@property ( assign ) int intAssign;
@property ( nonatomic ) int intNonatomic;
@property(nonatomic, readonly, copy) id idReadonlyCopyNonatomic;
@property (nonatomic, readonly , retain) id
idReadonlyRetainNonatomic;

- (void)resolveThisMethodDynamically;
- (void)negotiate;
@end

void (*setter)(id, SEL, BOOL);
int i;

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* ========== 2.Interacting with the Runtime ========== */
    NSLog(@"ViewContolller-description:%@",self.description);
    NSArray *array = @[@"a",@"b",@"c"];
    NSLog(@"array-description:%@",array.description);
    
    /* ========== 3.Messaging ========== */
    [self messagingSection];
    
    /* ========== 4.Dynamic Method Resolution ========== */
    [self dynamicMethodResolutionSection];
    
    /* ========== 5.Message Forwarding ========== */
    [self messageForwardingSection];
    
    /* ========== 6.Type Encodings ========== */
    [self typeEncodingsSection];
    
    /* ========== 7.Declared Properties ========== */
    [self declaredPropertiesSection];
    
}

#pragma mark - Messaging

- (void)messagingSection {
    NSLog(@" ========== 3.Messaging ========== ");
    
    // When the methed is called as a funciton.the receiving object(self)
    // and the method selecter(_cmd) must be made explicit.
    setter = (void(*)(id, SEL, BOOL))[self methodForSelector:@selector(setFilled:)];
    for (i = 0; i < 2; i++) {
        setter(self,@selector(setFilled:),YES);
    }
    
    // circumvent dynamic  binding and call the address of a mehtod.
    IMP imp = [self methodForSelector:@selector(setFilled:)];
    imp();
}
- (void)setFilled:(BOOL)value {
    NSLog(@"-setFilled: called");
}

#pragma mark - Dynamic Method Resolution

- (void)dynamicMethodResolutionSection {
    NSLog(@"\n");
    NSLog(@" ========== 4.Dynamic Method Resolution ========== ");
    
    // dynamic add mehtod implementation.
    [self resolveThisMethodDynamically];
}
/*
 dynamic add a method implementaion for 'resolveThisMethodDynamically'
 */
+ (BOOL)resolveInstanceMethod:(SEL)aSEL {
    if (aSEL == @selector(resolveThisMethodDynamically)) {
        class_addMethod([self class], aSEL, (IMP)dynamicMethodIMP, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:aSEL];
}

void dynamicMethodIMP(id self, SEL _cmd) {
    // implementation ....
    NSLog(@"this is resolveThisMethodDynamically called.");
}

#pragma mark - Message Forwarding

- (void)messageForwardingSection {
    NSLog(@"\n");
    NSLog(@" ========== 5.Message Forwarding ========== ");
    
    // Forwarding 'negotiate' message
    [self negotiate];
    
    Warrior *warrior = [Warrior new];
    [warrior negotiate];
    
    if ([warrior respondsToSelector:@selector(negotiate)]) {
        NSLog(@"warrior respond to selector negotiage - YES");
    }else {
        NSLog(@"warrior  respond to selector negotiage - NO");
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return  [OtherObject instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    OtherObject *otherObject = [[OtherObject alloc]init];
    if ([otherObject respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:otherObject];
    }else {
        [super forwardInvocation:anInvocation];
    }
}

#pragma mark - Type Encodings

- (void)typeEncodingsSection {
    NSLog(@"\n");
    NSLog(@" ========== 6.Type Encoding ========== ");
    /// encodes directive
    NSLog(@"int **: %s",@encode(int **));
    
    /* the difference between 'double' and 'long double' */
    NSLog(@"double: %s Double: %s",@encode(double),@encode(long double));
    
    /// float Array
    float a = 1.f;
    float b = 2.f;
    float * aPtr = &a;
    float * bPtr = &b;
    float  * floatPointerArray[2] = {aPtr,bPtr};
    NSLog(@"floatPointerArray: %s",@encode(typeof(floatPointerArray)));
    
    /// struct
    typedef struct example {
        char *aString;
        int  anInt;
    } Example;
    
    NSLog(@"struct example: %s",@encode(struct example));
    
    /// a union example
    union UINON {
        int i;
        float f;
        char str[10];
    };
    NSLog(@"a union [UNION]: %s", @encode(union UINON));
    
    /// NSObject is treated like structure.
    NSLog(@"NSObject: %s",@encode(NSObject));
    NSLog(@"NSObject * : %s",@encode(NSObject *));
    NSLog(@"[NSObject class]: %s", @encode(typeof([NSObject class])));
    
    /// a bit field of num bits
    struct bitField {
        unsigned int: 1; //  1-bit
        unsigned char : 2; // 2-bits
    };
    NSLog(@"The number of bits in the bit-field: %s", @encode(struct bitField));
    
    /// others:
    NSLog(@"a char: %s", @encode(char));
    NSLog(@"an int: %s", @encode(int));
    NSLog(@"a short: %s", @encode(short));
    NSLog(@"a long: %s", @encode(long));
    NSLog(@"a long long: %s", @encode(long long));
    NSLog(@"------ unsigend type ------");
    NSLog(@"an unsigned char: %s", @encode(unsigned char));
    NSLog(@"an unsigned int: %s", @encode(unsigned int));
    NSLog(@"an unsigned short: %s", @encode(unsigned short));
    NSLog(@"an unsigned long: %s", @encode(unsigned long));
    NSLog(@"an unsigned long long: %s", @encode(unsigned long long));
    NSLog(@"----- floating-point type ----- ");
    NSLog(@"a float: %s", @encode(float));
    NSLog(@"----- an object type ----");
    NSLog(@"a C++ bool: %s", @encode(bool));
    NSLog(@"a C99 _Bool: %s", @encode(_Bool));
    NSLog(@"a BOOL: %s", @encode(BOOL));
    NSLog(@"a Boolean: %s", @encode(Boolean));
    NSLog(@"a void: %s", @encode(void));
    NSLog(@"a pointer to type [void *]: %s", @encode(void *));
    NSLog(@"a character string [char *]: %s", @encode(char *));
    NSLog(@"an object [id]: %s", @encode(id));
    NSLog(@"a class object [Class]: %s", @encode(Class));
    NSLog(@"a method selector [SEL]: %s", @encode(SEL));
}

#pragma mark - Declared Properties

- (void)declaredPropertiesSection {
    NSLog(@"\n");
    NSLog(@" ========== 7.Declared Properties ========== ");
    // print all properties in this class.
    id vcClass = objc_getClass("ViewController");
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(vcClass, &outCount);
    for (i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        NSLog(@"%s  %s\n",property_getName(property), property_getAttributes(property));
    }
    
    /// get a reference to a property with 'class_getProperty' .
    objc_property_t property = class_getProperty(self.class, "alone");
    NSLog(@"property name: %s",property_getName(property));
}

@end
