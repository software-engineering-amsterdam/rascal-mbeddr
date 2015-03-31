#ifndef StateMachine_H
#define StateMachine_H

#define = (100);

#define = (10);

#define = (20);

#define = (100);

typedef enum StateMachines_FlightAnalyzer__states __StateMachines_FlightAnalyzer__states;

enum StateMachines_FlightAnalyzer__states {
  StateMachines_FlightAnalyzer__states__FlightAnalyzer_crashed__state;
  StateMachines_FlightAnalyzer__states__FlightAnalyzer_landed__state;
  StateMachines_FlightAnalyzer__states__FlightAnalyzer_beforeFlight__state;
  StateMachines_FlightAnalyzer__states__FlightAnalyzer_airborne__state;
  StateMachines_FlightAnalyzer__states__FlightAnalyzer_landing__state;
}

typedef enum StateMachines_FlightAnalyzer__inevents __StateMachines_FlightAnalyzer__inevents;

enum StateMachines_FlightAnalyzer__inevents {
  StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_reset__event;
  StateMachines_FlightAnalyzer__inevents__FlightAnalyzer_next__event;
}

typedef enum StateMachines_FlightAnalyzer__data_t __StateMachines_FlightAnalyzer__data_t;

struct StateMachines_FlightAnalyzer__data {
  StateMachines_FlightAnalyzer__state __currentState;
  int16_t points;
  int16_t[25] pointsArray;
}

void StateMachines_FlightAnalyzer__execute(StateMachines_FlightAnalyzer__data_t* instance,StateMachines_FlightAnalyzer__inevents event,void** arguments,);

void StateMachines_FlightAnalyzer__init(StateMachines_FlightAnalyzer__data_t* instance,);

void StateMachines_FlightAnalyzer__execute(StateMachines_FlightAnalyzer__data_t* instance,StateMachines_FlightAnalyzer__inevents event,void** arguments,);

void StateMachines_FlightAnalyzer__init(StateMachines_FlightAnalyzer__data_t* instance,);

TrackPoint* makeTP(int16_t alt,int16_t speed,);

int8_t test_TestFlightAnalyzer();
#endif