import 'package:flutter/material.dart';

class WorkExperience {
  String workExperienceID = '';
  String company = '';
  String jobTitle = '';
  String employmentType = '';
  String location = '';
  String locationType = '';
  bool isCurrentJob = false;
  String startDate = '';
  String endDate = '';
  String description = '';
  List<String> skills = [];

  // Constructor
  WorkExperience({
    required this.workExperienceID,
    required this.company,
    required this.jobTitle,
    //required this.employmentType,
    required this.location,
    //required this.locationType,
    required this.isCurrentJob,
    required this.startDate,
    required this.endDate,
    required this.description,
    //required this.skills,
  });
}

class WorkExperienceForm extends StatefulWidget {
  final Function(WorkExperience) onSave;
  final WorkExperience? initialWorkExperience; // Add this line

  const WorkExperienceForm(
      {Key? key, required this.onSave, this.initialWorkExperience})
      : super(key: key);

  @override
  _WorkExperienceFormState createState() => _WorkExperienceFormState();
}

class _WorkExperienceFormState extends State<WorkExperienceForm> {
  final _formKey = GlobalKey<FormState>();
  late WorkExperience workExperience;
  bool isCurrentJob = false;
  TextEditingController companyController = TextEditingController();
  TextEditingController jobTitleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    workExperience = widget.initialWorkExperience ??
        WorkExperience(
          workExperienceID: '',
          company: '',
          jobTitle: '',
          //employmentType: '',
          location: '',
          //locationType: '',
          isCurrentJob: false,
          startDate: '',
          endDate: '',
          description: '',
          //skills: [],
        );

    isCurrentJob = workExperience.isCurrentJob;

    companyController.text = workExperience.company;
    jobTitleController.text = workExperience.jobTitle;
    locationController.text = workExperience.location;
    startDateController.text = workExperience.startDate;
    endDateController.text = workExperience.endDate;
    descriptionController.text = workExperience.description;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: companyController,
            decoration: const InputDecoration(labelText: 'Company'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter company';
              }
              return null;
            },
            onSaved: (value) {
              workExperience.company = value!;
            },
          ),
          // Add other form fields here
          TextFormField(
            controller: jobTitleController,
            decoration: const InputDecoration(labelText: 'Job Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your job title';
              }
              return null;
            },
            onSaved: (value) {
              workExperience.jobTitle = value!;
            },
          ),
          TextFormField(
            controller: locationController,
            decoration: const InputDecoration(labelText: 'Location'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your location';
              }
              return null;
            },
            onSaved: (value) {
              workExperience.location = value!;
            },
          ),
          CheckboxListTile(
            title: const Text("Current Job"),
            value: isCurrentJob,
            onChanged: (value) {
              setState(() {
                isCurrentJob = value!;
                workExperience.isCurrentJob = value;
              });
            },
          ),
          TextFormField(
            controller: startDateController,
            decoration: const InputDecoration(
                labelText: 'Start Date', hintText: 'month, year'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter start date';
              }
              return null;
            },
            onSaved: (value) {
              workExperience.startDate = value!;
            },
          ),
          if (!isCurrentJob)
            TextFormField(
              controller: endDateController,
              decoration: const InputDecoration(
                  labelText: 'End Date', hintText: 'month, year'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter end date';
                }
                return null;
              },
              onSaved: (value) {
                workExperience.endDate = value!;
              },
            ),
          TextFormField(
            controller: descriptionController,
            maxLines: null,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your job description';
              }
              return null;
            },
            onSaved: (value) {
              workExperience.description = value!;
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (isCurrentJob) {
                  workExperience.endDate = "Current";
                }
                widget.onSave(workExperience);
                Navigator.of(context).pop();
              }
            },
            child: const Center(child: Text('Save')),
          ),
        ],
      ),
    );
  }
}
