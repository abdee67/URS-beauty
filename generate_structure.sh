#!/bin/bash

mkdir -p lib/{core/{constants,errors,network,theme,utils,widgets},shared/{models,widgets/{booking,beauty}},config,routes,features/{auth/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,screens,widgets}},home/{data/repositories,domain/usecases,presentation/{bloc,screens,widgets}},services/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,screens,widgets}},bookings/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,screens,widgets}},professionals/{data/models,presentation/{screens,widgets}},profile/{data/repositories,domain/usecases,presentation/{bloc,screens,widgets}},notifications/presentation/{screens,widgets},payments/{data/models,presentation/screens},reviews/presentation/{screens,widgets}}}

touch lib/main.dart lib/injection_container.dart lib/firebase_options.dart
