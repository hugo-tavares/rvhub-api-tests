package aplic;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.junit.Assert;
import org.junit.Test;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;

import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;

public abstract class BaseRunner {
	private final String projectName;
	private String environment;
	private static final String JSON_REPORT_DIR = "target/surefire-reports";

	private static final Integer THREAD_COUNT = 50;

	public BaseRunner(final String projectName) {
		this.projectName = projectName;
		this.environment = System.getProperty("karate.env");
		if (this.environment == null)
			this.environment = "dev";
	}

	@Test
	public void runParallel() {
		final Results resultados = Runner.parallel(this.getClass(), THREAD_COUNT, JSON_REPORT_DIR);

		final Double elapsedTime = resultados.getElapsedTime() / 1000;
		this.generateReport(resultados.getReportDir(), elapsedTime);
		Assert.assertTrue(resultados.getErrorMessages(), resultados.getFailCount() == 0);
	}


	public void generateReport(final String karateOutputPath, final Double elapsedTime) {
		final Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[] { "json" },
				true);
		final List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
		jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
		final Configuration config = new Configuration(new File("target"), this.projectName);
		config.setTagsToExcludeFromChart("@ignore");
		config.addClassifications("Ambiente", this.environment);
		config.addClassifications("Tempo de Execução dos Testes", elapsedTime.toString() + "s");
		final ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
		reportBuilder.generateReports();
	}

}