<?php

declare(strict_types=1);

namespace App\Commands;

use Illuminate\Contracts\Container\BindingResolutionException;

/**
 * @author      Andreas Knollmann
 * @copyright   2014-2026 Softwareentwicklung Andreas Knollmann
 * @license     http://www.opensource.org/licenses/mit-license.php MIT
 */
class Import extends Base
{
    protected function getCommandName(): string
    {
        return 'import';
    }

    protected function getCommandDescription(): string
    {
        return 'Import a dump file';
    }

    protected function getCommandParameters(): array
    {
        return [
            $this->prepareInputOption('file', 'Import file'),
            $this->prepareInputFlag('reset', 'Drop current database and re-create it'),
            $this->prepareDefaultInputOption('tempDir', '/tmp/redam', 'Path to temp directory, default: /tmp/redam'),
            $this->prepareInputFlag('remove', 'Remove import file after import'),
        ];
    }

    /**
     * @throws BindingResolutionException
     */
    protected function executeCommand(): int
    {
        $file = $this->getRequiredOption('file', 'No import file specified!');
        $reset = $this->getFlag('reset');
        $tempDir = $this->getRequiredOption('tempDir', 'No temp directory specified!');
        $remove = $this->getFlag('remove');

        $process = $this->app->make(\App\Models\Process\Import::class);

        $process->execute(
            $this->getOutput(),
            $file,
            $reset,
            $tempDir,
            $remove
        );

        return self::SUCCESS;
    }
}
