#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { IaCKafkaEC2Stack } from '../lib/cdk-stack';

const envVariables = {
	projectName: process.env["PROJECT_NAME"] ?? "",
	region: process.env["AWS_REGION"] ?? "",
	accountId: process.env["AWS_ACCOUNT_ID"] ?? "",
};

const app = new cdk.App();
new IaCKafkaEC2Stack(app, 'IaCKafkaEC2', { ...envVariables });