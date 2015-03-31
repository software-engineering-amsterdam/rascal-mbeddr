#include StateMachine_H

static int16_t[25] comprehension_function_$1() {
  int16_t[25] result = ((malloc)(10));
  int32_t i = 0;
  int32_t j = 0;
  for (; (i<25); (i++)) {
    int16_t x = (input[i]);
    if ((x<=10)) {
      ((result[j])=(x+10));
      (j++);
    }
  }
  return result;
}

static typedef struct TrackPoint TrackPoint;

static struct TrackPoint {
  int8_t id;
  int32_t time;
  int32_t alt;
  int32_t speed;
}

static void raiseAlarm() {

}

inline static void StateMachines_FlightAnalyzer__crashed_EntryAction0(StateMachines_FlightAnalyzer__data_t* instance,) {
  ;
}

inline static void StateMachines_FlightAnalyzer__landed_EntryAction0(StateMachines_FlightAnalyzer__data_t* instance,) {
  ((instance->points)+=LANDING);
  ((instance->pointsArray)=((comprehension_function_$1)()));
}

inline static void StateMachines_FlightAnalyzer__beforeFlight_EntryAction0(StateMachines_FlightAnalyzer__data_t* instance,) {
  ((instance->points)=0);
}

inline static void StateMachines_FlightAnalyzer__airborne_EntryAction0(StateMachines_FlightAnalyzer__data_t* instance,) {
  ((instance->points)=100);
}

inline static void StateMachines_FlightAnalyzer__beforeFlight_ExitAction0(StateMachines_FlightAnalyzer__data_t* instance,) {
  ((instance->points)+=TAKEOFF);
}

void StateMachines_FlightAnalyzer__execute(StateMachines_FlightAnalyzer__data_t* instance,StateMachines_FlightAnalyzer__inevents event,void** arguments,) {
  switch ((instance->__currentState)) {
    case StateMachines_FlightAnalyzer__states__FlightAnalyzer_crashed__state: {
      switch (event) {

      }
    }
    case StateMachines_FlightAnalyzer__states__FlightAnalyzer_landed__state: {
      switch (event) {
        case StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_reset__event: {
          if (1) {
            {

            }
            ((instance->__currentState)=beforeFlight);
            ((StateMachines_FlightAnalyzer__EntryAction0)(instance));
            return;
          }
        }
      }
    }
    case StateMachines_FlightAnalyzer__states__FlightAnalyzer_beforeFlight__state: {
      switch (event) {
        case StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_next__event: {
          if ((((*((TrackPoint**)(arguments[0])))->alt)>0)) {
            {

            }
            ((StateMachines_FlightAnalyzer__ExitAction0)(instance));
            ((instance->__currentState)=airborne);
            ((StateMachines_FlightAnalyzer__EntryAction0)(instance));
            return;
          }
        }
      }
    }
    case StateMachines_FlightAnalyzer__states__FlightAnalyzer_airborne__state: {
      switch (event) {
        case StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_reset__event: {
          if (1) {
            {

            }
            ((instance->__currentState)=beforeFlight);
            ((StateMachines_FlightAnalyzer__EntryAction0)(instance));
            return;
          }
        }
        case StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_next__event: {
          if ((((((*((TrackPoint**)(arguments[0])))->alt)==0)&&(((*((TrackPoint**)(arguments[0])))->speed)==0))&&((instance->points)==0))) {
            {

            }
            ((instance->__currentState)=crashed);
            ((StateMachines_FlightAnalyzer__EntryAction0)(instance));
            return;
          }
          if (((((*((TrackPoint**)(arguments[0])))->alt)==0)&&(((*((TrackPoint**)(arguments[0])))->speed)>0))) {
            {

            }
            ((instance->__currentState)=landed);
            ((StateMachines_FlightAnalyzer__EntryAction0)(instance));
            return;
          }
          if (((((*((TrackPoint**)(arguments[0])))->speed)>200)&&(((*((TrackPoint**)(arguments[0])))->alt)==0))) {
            {
              ((instance->points)+=VERY_HIGH_SPEED);
            }
            ((instance->__currentState)=airborne);
            ((StateMachines_FlightAnalyzer__EntryAction0)(instance));
            return;
          }
          if ((((((*((TrackPoint**)(arguments[0])))->speed)>100)&&(((*((TrackPoint**)(arguments[0])))->speed)<=200))&&(((*((TrackPoint**)(arguments[0])))->alt)==0))) {
            {
              ((instance->points)+=HIGH_SPEED);
            }
            ((instance->__currentState)=airborne);
            ((StateMachines_FlightAnalyzer__EntryAction0)(instance));
            return;
          }
        }
      }
    }
    case StateMachines_FlightAnalyzer__states__FlightAnalyzer_landing__state: {
      switch (event) {
        case StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_reset__event: {
          if (1) {
            {

            }
            ((instance->__currentState)=beforeFlight);
            ((StateMachines_FlightAnalyzer__EntryAction0)(instance));
            return;
          }
        }
        case StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_next__event: {
          if ((((*((TrackPoint**)(arguments[0])))->speed)==0)) {
            {

            }
            ((instance->__currentState)=landed);
            ((StateMachines_FlightAnalyzer__EntryAction0)(instance));
            return;
          }
          if ((((*((TrackPoint**)(arguments[0])))->speed)>0)) {
            {
              ((instance->points)--);
            }
            ((instance->__currentState)=landing);
            return;
          }
        }
      }
    }
  }
}

void StateMachines_FlightAnalyzer__init(StateMachines_FlightAnalyzer__data_t* instance,) {
  ((instance->points)=0);
  ((instance->pointsArray)=((int16_t[25])0));
}

TrackPoint* makeTP(int16_t alt,int16_t speed,) {
  static int8_t trackPointCounter = 0;
  (trackPointCounter++);
  TrackPoint* tp = ((TrackPoint*)100);
  ((tp->id)=trackPointCounter);
  ((tp->time)=trackPointCounter);
  ((tp->alt)=alt);
  ((tp->speed)=speed);
  return tp;
}

int8_t test_TestFlightAnalyzer() {
  int8_t failures = 0;
  ((printf)("running test @StateMachine:test_TestFlightAnalyzer:0
"));
  static StateMachines_FlightAnalyzer__data_t f;
  ((StateMachines_FlightAnalyzer__init)((&f)));
  ((f.__currentState)=StateMachines_FlightAnalyzer__states__FlightAnalyzer_airborne__state);
  if ((!((f.__currentState)==StateMachines_FlightAnalyzer__states__FlightAnalyzer_beforeFlight__state))) {
    (failures++);
    ((printf)("FAILED: @StateMachine:test_TestFlightAnalyzer:1
"));
    ((printf)("testID = |project://rascal-mbeddr/input/statemachine.mbdr|(1769,37,<80,1>,<80,38>)
"));
  }
  if ((!((f.points)==0))) {
    (failures++);
    ((printf)("FAILED: @StateMachine:test_TestFlightAnalyzer:2
"));
    ((printf)("testID = |project://rascal-mbeddr/input/statemachine.mbdr|(1808,21,<81,1>,<81,22>)
"));
  }
  {
    ((*(___args[1]))=(&((makeTP)(0, 20))));
    ((StateMachines_FlightAnalyzer__execute)((&f), StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_next__event, ___args));
  }
  if ((!(((f.__currentState)==StateMachines_FlightAnalyzer__states__FlightAnalyzer_beforeFlight__state)&&((f.points)==0)))) {
    (failures++);
    ((printf)("FAILED: @StateMachine:test_TestFlightAnalyzer:3
"));
    ((printf)("testID = |project://rascal-mbeddr/input/statemachine.mbdr|(1861,54,<85,1>,<85,55>)
"));
  }
  {
    ((*(___args[1]))=(&((makeTP)(100, 100))));
    ((StateMachines_FlightAnalyzer__execute)((&f), StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_next__event, ___args));
  }
  if ((!(((f.__currentState)==StateMachines_FlightAnalyzer__states__FlightAnalyzer_airborne__state)&&((f.points)==100)))) {
    (failures++);
    ((printf)("FAILED: @StateMachine:test_TestFlightAnalyzer:4
"));
    ((printf)("testID = |project://rascal-mbeddr/input/statemachine.mbdr|(1950,52,<89,1>,<89,53>)
"));
  }
  {
    ((*(___args[1]))=(&((makeTP)(200, 100))));
    ((StateMachines_FlightAnalyzer__execute)((&f), StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_next__event, ___args));
  }
  if ((!((f.__currentState)==StateMachines_FlightAnalyzer__states__FlightAnalyzer_airborne__state))) {
    (failures++);
    ((printf)("FAILED: @StateMachine:test_TestFlightAnalyzer:5
"));
    ((printf)("testID = |project://rascal-mbeddr/input/statemachine.mbdr|(2037,33,<92,1>,<92,34>)
"));
  }
  {
    ((*(___args[1]))=(&((makeTP)(300, 150))));
    ((StateMachines_FlightAnalyzer__execute)((&f), StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_next__event, ___args));
  }
  if ((!((f.__currentState)==StateMachines_FlightAnalyzer__states__FlightAnalyzer_airborne__state))) {
    (failures++);
    ((printf)("FAILED: @StateMachine:test_TestFlightAnalyzer:6
"));
    ((printf)("testID = |project://rascal-mbeddr/input/statemachine.mbdr|(2103,33,<94,1>,<94,34>)
"));
  }
  {
    ((*(___args[1]))=(&((makeTP)(0, 90))));
    ((StateMachines_FlightAnalyzer__execute)((&f), StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_next__event, ___args));
  }
  if ((!((f.__currentState)==StateMachines_FlightAnalyzer__states__FlightAnalyzer_landing__state))) {
    (failures++);
    ((printf)("FAILED: @StateMachine:test_TestFlightAnalyzer:7
"));
    ((printf)("testID = |project://rascal-mbeddr/input/statemachine.mbdr|(2166,32,<96,1>,<96,33>)
"));
  }
  {
    ((*(___args[1]))=(&((makeTP)(0, 0))));
    ((StateMachines_FlightAnalyzer__execute)((&f), StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_next__event, ___args));
  }
  if ((!((f.__currentState)==StateMachines_FlightAnalyzer__states__FlightAnalyzer_landed__state))) {
    (failures++);
    ((printf)("FAILED: @StateMachine:test_TestFlightAnalyzer:8
"));
    ((printf)("testID = |project://rascal-mbeddr/input/statemachine.mbdr|(2227,31,<98,1>,<98,32>)
"));
  }
  return failures;
}